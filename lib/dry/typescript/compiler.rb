# frozen_string_literal: true

require "dry-struct"
require "dry-initializer"

require 'dry/typescript/ast_parser'
require 'dry/typescript/ts_types/reference'

module Dry
  module Typescript
    class Compiler
      extend Dry::Initializer

      param :registry, type: DryTypes.Interface(:each)

      BuildError               = Class.new(StandardError)
      NamespaceResolutionError = Class.new(StandardError)
      ConversionError          = Class.new(StandardError)

      def compile
        @ts_to_dry_map = {}
        namespace = build(registry)

        namespace.map do |name, ts_type|
          ts_type = resolve_namespace_references(ts_type, name: name, namespace: namespace)

          begin
            ts_type.to_typescript(name)
          rescue StandardError => e
            raise ConversionError, "Encountered error in #to_typescript for #{name}: #{e}"
          end
        end
      end

      def build(registry)
        namespace = {}

        registry.each do |constant_name, dry_type|
          ts_type = AstParser.visit(dry_type.to_ast)
          @ts_to_dry_map[ts_type] = dry_type
          namespace[ts_type.name || constant_name] = ts_type
        rescue StandardError => e
          raise BuildError, "Error during build while processing constant #{constant_name}: #{e}"
        end

        namespace
      end

      def resolve_namespace_references(ts_type, namespace:, name:)
        return ts_type unless ts_type.respond_to?(:with_transformed_types)

        ts_type.with_transformed_types do |contained_type|
          dry_type = @ts_to_dry_map.fetch(contained_type, nil)
          next contained_type if dry_type.nil?

          found_names = namespace.select do |_, namespace_type|
            dry_type == @ts_to_dry_map.fetch(namespace_type, nil)
          end.map(&:first)

          type_name = found_names.last

          Warning.warn "[dry-typescript] Duplicate types found while trying to resolve references within #{name}: #{found_names.join(", ")}. " \
                         "By default, dry-typescript will use #{type_name}. If this is not the intended choice, you can add type aliases " \
                         "to the duplicate types by using `.ts('Alias')` on the dry-types definition." if found_names.count > 1

          type_name.nil? ? contained_type : TsTypes::Reference.new(name: type_name.to_s)
        end
      rescue StandardError => e
        raise NamespaceResolutionError, "Error while resolving namespace references for #{name}: #{e}"
      end
    end
  end
end

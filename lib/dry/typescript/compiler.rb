# frozen_string_literal: true

require "dry-struct"
require "dry-initializer"

require 'dry/typescript/ast_parser'
require 'dry/typescript/ts_types/reference'

module Dry
  module Typescript
    class Compiler
      extend Dry::Initializer

      param :mod,       type: DryTypes.Instance(Module)

      CompilerError = Class.new(StandardError)

      def compile
        @ts_to_dry_map = {}
        namespace = build(mod)

        namespace.map do |name, ts_type|
          ts_type = resolve_namespace_references(ts_type, name: name, namespace: namespace)
          ts_type.to_typescript(name)
        end
      end

      def build(mod)
        mod.constants.map do |constant_name|
          constant = mod.const_get(constant_name)
          ts_type  = AstParser.visit(constant.to_ast)
          @ts_to_dry_map[ts_type] = constant
          [ts_type.name || constant_name, ts_type]
        rescue StandardError => e
          raise CompilerError, "Error during build while processing constant #{constant_name}: #{e.message}"
        end.to_h
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
      end
    end
  end
end

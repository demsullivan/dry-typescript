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

      def compile
        @ts_to_dry_map = {}
        namespace = build(mod)

        namespace.map do |name, ts_type|
          ts_type = resolve_namespace_references(namespace, ts_type)
          ts_type.to_typescript(name)
        end
      end

      def build(mod)
        mod.constants.map do |constant_name|
          constant = mod.const_get(constant_name)
          ts_type  = AstParser.visit(constant.to_ast)
          @ts_to_dry_map[ts_type] = constant
          [ts_type.name || constant_name, ts_type]
        end.to_h
      end

      def resolve_namespace_references(namespace, ts_type)
        return ts_type unless ts_type.respond_to?(:with_transformed_types)

        ts_type.with_transformed_types do |contained_type|
          dry_type = @ts_to_dry_map.fetch(contained_type, nil)
          next contained_type if dry_type.nil?

          found_names = namespace.select do |_, namespace_type|
            dry_type == @ts_to_dry_map.fetch(namespace_type, nil)
          end.map(&:first)

          type_name = found_names.first

          puts "Duplicate types found: #{found_names.join(", ")}; using #{type_name}" if found_names.count > 1

          type_name.nil? ? contained_type : TsTypes::Reference.new(name: type_name.to_s)
        end
      end
    end
  end
end

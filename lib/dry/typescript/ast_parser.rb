# frozen_string_literal: true

require "dry-struct"
require_relative "./ts_types/primitive"
require_relative "./ts_types/object"
require_relative "./ts_types/union"
require_relative "./ts_types/enum"
require_relative "./ts_types/array"

module Dry
  module Typescript
    module AstParser
      UnknownNodeTypeError = Class.new(StandardError)

      def self.visit(node)
        meth, rest = node

        raise UnknownNodeTypeError, "Unknown dry-types AST node type: #{meth}" unless respond_to?(:"visit_#{meth}")

        public_send(:"visit_#{meth}", rest)
      end

      def self.visit_constrained(constraints)
        ts_type, _ = constraints.map { |constraint| visit(constraint) }
        ts_type
      end

      def self.visit_sum(rest)
        types = rest.map { |type| type.is_a?(Array) ? visit(type) : nil }.compact
        type = TsTypes::Union.new(types: types)

        if type.boolean?
          TsTypes::Primitive.new(type_name: "boolean")
        else
          type
        end
      end

      def self.visit_enum(rest)
        TsTypes::Enum.new(values: rest.last)
      end

      def self.visit_struct(rest)
        _, rest = rest

        ts_type, _ = visit(rest)

        TsTypes::Object.new(
          schema:    ts_type.schema,
          render_as: "interface"
        )
      end

      def self.visit_constructor(rest)
        mapped = rest.map { |node| visit(node) }
      end

      def self.visit_schema(rest)
        definitions, _, meta = rest

        schema = definitions
          .map { |definition| visit(definition) }
          .reduce({}, &:merge)

        TsTypes::Object.new(name: meta.dig(:ts, :name), schema: schema)
      end

      def self.visit_key(rest)
        name, required, opts = rest

        name = required ? name : "#{name}?"

        { name => visit(opts) }
      end

      def self.visit_any(_rest)
        TsTypes::Primitive.new(type_name: "any")
      end

      def self.visit_array(rest)
        rest, meta = rest
        TsTypes::Array.new(name: meta.dig(:ts, :name), type: visit(rest))
      end

      def self.visit_nominal(rest)
        type, meta = rest

        TsTypes::Primitive.new(name: meta.dig(:ts, :name), type_name: type)
      end

      def self.visit_hash(_rest)
        TsTypes::Object.new(schema: {})
      end

      def self.visit_predicate(_rest)
        {}
      end

      def self.visit_method(_rest)
        {}
      end
    end
  end
end

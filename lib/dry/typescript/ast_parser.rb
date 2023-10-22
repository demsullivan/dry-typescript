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
        ts_type, opts = constraints.map { |constraint| visit(constraint) }

        ts_type
      end

      def self.visit_sum(rest)
        types = rest.map { |type| type.is_a?(Array) ? visit(type) : nil }.compact
        type = TsTypes::Union.new(types: types)

        if type.is_boolean?
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
        definitions, _ = rest
        schema = definitions
          .map { |definition| visit(definition) }
          .reduce({}, &:merge)

        TsTypes::Object.new(schema: schema)
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
        TsTypes::Array.new(type: visit(rest.first))
      end

      def self.visit_nominal(rest)
        type, _ = rest

        TsTypes::Primitive.new(type_name: type)
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

      def self.build_hash_schema(constraints)
        constraints.map { |constraint| visit(constraint) }.reduce({}, &:merge)
      end

      def self.extract_array_element_type(constraints)
        extracted = constraints.map { |constraint| visit(constraint) }.reduce({}, &:merge)
        extracted[:array]
      rescue StandardError
        TsTypes::Primitive.new(type_name: "any")
      end

      def self.constrained_type(constraints)
        predicates = constraints.find { |constraint| constraint[0] == :predicate }
        type_predicate = predicates.find { |predicates| predicates[0] == :type? }

        type_predicate[1].find { |type| type[0] == :type }[1]
      end
    end
  end
end

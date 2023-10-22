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
        type = constrained_type(constraints)

        if type == Hash
          hsh = build_hash_schema(constraints)
          TsTypes::Object.new(schema: hsh)
        elsif type == Array
          element_type = extract_array_element_type(constraints)
          TsTypes::Array.new(type: element_type)
        else
          TsTypes::Primitive.new(type_name: type)
        end
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
        hsh = build_hash_schema(rest.dig(1, 1))
        TsTypes::Object.new(schema: hsh, interface: true)
      end

      def self.visit_schema(rest)
        definitions = rest[0]
        definitions
          .map { |definition| visit(definition) }
          .reduce({}, &:merge)
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
        { array: visit(rest.first) }
      end

      def self.visit_hash(_rest)
        {}
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

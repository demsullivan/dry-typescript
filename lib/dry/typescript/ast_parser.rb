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
      UnknownError =         Class.new(StandardError)
      NodeError =            Class.new(StandardError)

      def self.visit(node)
        meth, rest = node

        raise UnknownNodeTypeError, "Unknown dry-types AST node type: #{meth}" unless respond_to?(:"visit_#{meth}")

        public_send(:"visit_#{meth}", rest)
      rescue NodeError => e
        raise
      rescue StandardError => e
        raise UnknownError, "Encountered an error while parsing AST node: #{node.inspect}\n\n#{e.message}}"
      end

      def self.visit_constrained(constraints)
        ts_type, _ = constraints.map { |constraint| visit(constraint) }
        ts_type
      end

      def self.visit_sum(rest)
        types = rest.map { |type| type.is_a?(Array) ? visit(type) : nil }.flatten.compact
        type = TsTypes::Union.new(types: types)

        if type.boolean?
          TsTypes::Primitive.new(type_name: "boolean")
        else
          type
        end
      rescue Dry::Struct::Error => e
        raise NodeError, "Error parsing sum node: #{rest.inspect}\n\n#{e.message}"
      end

      def self.visit_enum(rest)
        TsTypes::Enum.new(values: rest.last)
      rescue Dry::Struct::Error => e
        raise NodeError, "Error parsing enum node: #{rest.inspect}\n\n#{e.message}"
      end

      def self.visit_struct(rest)
        _, rest = rest

        ts_type, _ = visit(rest)

        TsTypes::Object.new(
          schema:    ts_type.schema,
          render_as: "interface"
        )
      rescue Dry::Struct::Error => e
        raise NodeError, "Error parsing struct node: #{rest.inspect}\n\n#{e.message}"
      end

      def self.visit_constructor(rest)
        ts_type, _ = rest.map { |node| visit(node) }
        ts_type
      rescue Dry::Struct::Error => e
        raise NodeError, "Error parsing constructor node: #{rest.inspect}\n\n#{e.message}"
      end

      def self.visit_schema(rest)
        definitions, _, meta = rest

        schema = definitions
          .map { |definition| visit(definition) }
          .compact
          .reduce({}, &:merge)

        TsTypes::Object.new(name: meta.dig(:ts, :name), schema: schema)
      rescue Dry::Struct::Error => e
        raise NodeError, "Error parsing schema node: #{rest.inspect}\n\n#{e.message}"
      end

      def self.visit_key(rest)
        name, required, opts = rest

        name = required ? name : "#{name}?"

        { name => visit(opts) }
      rescue Dry::Struct::Error => e
        raise NodeError, "Error parsing key node: #{rest.inspect}\n\n#{e.message}"
      end

      def self.visit_any(_rest)
        TsTypes::Primitive.new(type_name: "any")
      end

      def self.visit_array(rest)
        rest, meta = rest
        TsTypes::Array.new(name: meta.dig(:ts, :name), type: visit(rest))
      rescue Dry::Struct::Error => e
        raise NodeError, "Error parsing array node: #{rest.inspect}\n\n#{e.message}"
      end

      def self.visit_nominal(rest)
        type, meta = rest

        TsTypes::Primitive.new(name: meta.dig(:ts, :name), type_name: type)
      rescue Dry::Struct::Error => e
        raise NodeError, "Error parsing nominal node: #{rest.inspect}\n\n#{e.message}"
      end

      def self.visit_hash(_rest)
        TsTypes::Object.new(schema: {})
      end

      def self.visit_predicate(_rest)
        nil
      end

      def self.visit_method(_rest)
        nil
      end

      def self.visit_id(_rest)
        nil
      end
    end
  end
end

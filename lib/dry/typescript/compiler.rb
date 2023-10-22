# frozen_string_literal: true

require 'dry-struct'
require_relative './ast_parser'

module Dry
  module Typescript
    class Compiler

      class UnsupportedTypeError < StandardError; end

      def initialize(subject)
        @subject = subject
        @namespace    = {}
      end

      def compile
        visit(@subject)
        resolve_namespace_references

        @namespace.map do |name, entity|
          entity.to_typescript(name)
        end
      end

      def visit(node)
        if node.is_a?(Module) && !(node < Dry::Struct)
          visit_module(node)
        else
          AstParser.visit(node.to_ast)
        end
      end

      def resolve_namespace_references

      end

      def visit_module(node, name: nil)
        node.constants.map do |constant_name|
          constant = node.const_get(constant_name)

          result = visit(constant)
          @namespace[constant_name] = result
        end
      end
    end
  end
end

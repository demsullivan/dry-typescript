# frozen_string_literal: true

require "dry-struct"
require_relative "./ast_parser"

module Dry
  module Typescript
    class Compiler

      def initialize(subject)
        @subject = subject
        @namespace = {}
      end

      def compile
        visit(@subject)
        resolve_namespace_references

        @namespace.map do |name, entity|
          entity.to_typescript(name)
        end
      end

      def visit(node)
        # a Dry::Struct is a Module? so we explicitly check
        # for them, because they shouldn't be treated as modules
        # for the purposes of this compiler
        if node.is_a?(Module) && !(node < Dry::Struct)
          visit_module(node)
        else
          AstParser.visit(node.to_ast)
        end
      end

      def resolve_namespace_references; end

      def visit_module(node)
        node.constants.map do |constant_name|
          constant = node.const_get(constant_name)
          @namespace[constant_name] = visit(constant)
        end
      end
    end
  end
end

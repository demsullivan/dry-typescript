# frozen_string_literal: true

require "dry-struct"
require "dry-initializer"

require_relative "./ast_parser"

module Dry
  module Typescript
    class Compiler
      extend Dry::Initializer

      param :subject,   type: DryTypes.Instance(Module)
      param :namespace, default: -> { {} }

      def compile
        visit(subject)
        resolve_namespace_references

        namespace.map do |name, entity|
          entity.to_typescript(name)
        end
      end

      def visit(node)
        # a Dry::Struct is a Module? so we explicitly check
        # for them, because they shouldn't be treated as modules
        # for the purposes of this compiler

        return nil if skip?(node)

        if crawlable_module?(node)
          visit_module(node)
        else
          AstParser.visit(node.to_ast)
        end
      end

      def resolve_namespace_references; end

      def visit_module(node)
        node.constants.map do |constant_name|
          constant = node.const_get(constant_name)
          ts_type = visit(constant)
          namespace[constant_name] = ts_type
        end
      end

      def skip?(node)
        node.to_s =~ /Dry::Types::Module/
      end

      def crawlable_module?(mod)
        mod.is_a?(Module) && !(mod < Dry::Struct)
      end
    end
  end
end

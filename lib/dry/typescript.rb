# frozen_string_literal: true

require 'dry-types'
require 'dry/typescript/version'
require 'dry/typescript/namespace'

module Dry
  module Typescript
    def self.included(*)
      raise "use extend with Dry::Typescript, not include"
    end

    def self.extended(base)
      Dry::Types.define_builder(:ts_alias, &method(:add_alias_to_type)) unless Dry::Types::Builder.method_defined?(:ts_alias)
    end

    def self.add_alias_to_type(type, name)
      ts = type.meta.fetch(:ts, {})
      type.meta(ts: ts.merge(name: name))
    end

    def self.export(namespaces = [Namespace], filename: nil)
      compiler = Compiler.new(namespaces.inject(&:merge))
      type_definitions = compiler.compile

      if filename
        File.open(filename, "w+") do |file|
          type_definitions.each do |type_definition|
            file.write(type_definition)
          end
        end
      end

      type_definitions
    end

    def ts_export(type)
      Namespace.define(self, type)
    end
  end
end

require 'dry/typescript/dry_types'
require 'dry/typescript/compiler'
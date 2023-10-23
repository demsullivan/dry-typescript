# frozen_string_literal: true

require 'dry-types'
require 'dry/typescript/version'


module Dry
  module Typescript
    def self.included(*)
      raise "use extend with Dry::Typescript, not include"
    end

    def self.extended(base)
      @registry ||= []
      @registry << base

      # TODO: figure out how to do this only once...
      Dry::Types.define_builder(:ts, &method(:typescript_builder))
    end

    def self.typescript_builder(type, name_or_opts=nil, opts={})
      if name_or_opts.is_a?(Hash)
        opts = name_or_opts
        name = nil
      elsif name_or_opts.is_a?(String) || name_or_opts.is_a?(Symbol)
        name = name_or_opts
      else
        raise ArgumentError, ".ts expects at least a String, Symbol, or Hash of options, received #{name_or_opts.inspect}"
      end

      ts = type.meta.fetch(:ts, {})
      type.meta(ts: ts.merge(name: name || ts.fetch(:name, nil), **opts))
    end

    def self.generate(types_module, filename: nil)
      compiler = Compiler.new(types_module)
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

    def self.generate_from_registry(filename: nil)
      @registry.map do |types_module|
        generate(types_module, filename: filename)
      end.flatten
    end

    def to_typescript(filename: nil)
      Dry::Typescript.generate(self, filename: filename)
    end
  end
end

require 'dry/typescript/dry_types'
require 'dry/typescript/compiler'
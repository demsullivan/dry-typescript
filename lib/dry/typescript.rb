# frozen_string_literal: true

require 'dry-types'
require 'dry/typescript/version'

module Dry
  module Typescript

    # Maintains a global namespace of types to be exported.
    # Differs from @__dry_ts_constants which is specific to a given module.
    Namespace = {}

    def self.included(*)
      raise "use extend with Dry::Typescript, not include"
    end

    def self.extended(base)
      Dry::Types.define_builder(:ts_alias, &method(:add_alias_to_type)) unless Dry::Types::Builder.method_defined?(:ts_alias)

      trace = TracePoint.new(:line) do |tp|
        if base == tp.self && tp.path != __FILE__
          base.extract_constants!
        end
      end

      base.instance_variable_set(:"@__dry_ts_trace", trace)
      base.instance_variable_set(:"@__dry_ts_constants", {})

      trace.enable
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

    def ts_export(type_or_module)
      if type_or_module.is_a?(Module) && !(type_or_module < Dry::Struct)
        ts_export_module(type_or_module)
      else
        add_const_to_namespace(type_or_module)
        extract_constants!
      end
    end

    def extract_constants!
      constants(false).each do |const_name|
        next unless (const = const_get(const_name)).class.ancestors.include?(Dry::Types::Type)

        @__dry_ts_constants[const_name] = const.ts_alias(const_name.to_s)
        remove_const(const_name)
      end
    end

    def add_const_to_namespace(const, name: nil)
      name = constants(false).find { |const_name| const_get(const_name) == const } if name.nil?
      Namespace[name] ||= const.ts_alias(name.to_s)
    end

    def const_missing(const_name)
      super unless @__dry_ts_constants.has_key?(const_name)

      unless Namespace.has_key?(const_name)
        Warning.warn "[dry-typescript] WARN Found reference to unexported constant #{self}::#{const_name}; automatically exporting it.\n"
      end

      add_const_to_namespace(@__dry_ts_constants[const_name], name: const_name)
      @__dry_ts_constants[const_name]
    end

    def finalize_ts_exports!
      @__dry_ts_trace.disable

      @__dry_ts_constants.each do |const_name, const|
        const_set(const_name, const)
      end

      @__dry_ts_trace     = nil
      @__dry_ts_constants = nil
    end

    def ts_export_all
      # This has to be called at the bottom of the module, so that all of the constants
      # are already defined.
      ts_export_module(self)
    end

    def ts_export_module(type_module)
      type_module.constants(false).each do |const_name|
        next unless (const = type_module.const_get(const_name)).class.ancestors.include?(Dry::Types::Type)

        add_const_to_namespace(const, name: const_name)
      end
    end
  end
end

require 'dry/typescript/dry_types'
require 'dry/typescript/compiler'
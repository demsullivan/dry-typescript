# frozen_string_literal: true

module Dry
  module Typescript
    module Namespace
      def self.define(mod, type = nil)
        @registry      ||= {}
        @registry[mod] ||= []

        if type.nil?
          @registry[mod] = :__all__
        elsif @registry[mod] != :__all__
          @registry[mod] << type
        end
      end

      def self.merge(other)
        @registry.merge!(other.registry)
      end

      def self.each(&block)
        resolved.each(&block)
      end

      def self.registry
        @registry
      end

      def self.clear!
        @registry = {}
      end

      def self.resolved
        @duplicate_names = []

        @registry.reduce({}) do |registry_memo, (mod, types)|
          resolved_types = types == :__all__ ? resolve_types_from_module(mod) : resolve_types(mod, types)

          registry_memo.merge(resolved_types)
        end
      end

      def self.resolve_types_from_module(mod)
        mod.constants.reduce({}) do |types_memo, const_name|
          type = mod.const_get(const_name)
          type_alias = type.meta.dig(:ts, :name)

          types_memo.merge( type_alias || const_name => type)
        end
      end

      def self.resolve_types(mod, types)
        types.reduce({}) do |types_memo, type|
          type_alias = type.meta.dig(:ts, :name)

          next types_memo.merge(type_alias.to_sym => type) if type_alias

          found_names = mod.constants.select { |const_name| mod.const_get(const_name) == type }
          type_name = found_names.first

          if found_names.count > 1 && !@duplicate_names.include?(type_name)
            @duplicate_names += found_names

            Warning.warn "[dry-typescript] Duplicate names found for identical type: #{found_names.join(", ")}. " \
                           "By default, dry-typescript will use #{type_name} for all later references to this type. " \
                           "If this is not the intended choice, you can add type aliases to the duplicate types using .ts_alias. "\
                           "For example: `ts_export #{found_names[1]} = YourType.ts_alias('#{found_names[1]}')`\n\n"
          end

          types_memo.merge(type_name => type)
        end
      end
    end
  end
end

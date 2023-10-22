# frozen_string_literal: true

require_relative './type'
require 'json'

module Dry
  module Typescript
    module Types
      class Enum < Type
        option :values

        class InvalidEnumError < StandardError; end

        def to_typescript(name_override=nil)
          name = name_override || self.name

          return nil if name.nil?
          "export enum #{name} {\n#{typescript_value}\n}\n"
        end

        def typescript_value
          raise InvalidEnumError, "Enums must have string or symbol keys" \
            unless values.all? { |key, _| key.is_a?(String) || key.is_a?(Symbol) }

          values.map { |name, value| "  #{name.upcase} = #{JSON.generate(value)}" }.join(",\n")
        end
      end
    end
  end
end

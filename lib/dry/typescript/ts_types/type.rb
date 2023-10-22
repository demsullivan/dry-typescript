# frozen_string_literal: true

require "dry-struct"
require "dry/typescript/dry_types"

module Dry
  module Typescript
    module TsTypes
      class Type < Dry::Struct
        attribute? :name, DryTypes::String

        def to_typescript(name_override = nil)
          name = name_override || self.name

          if !name.nil?
            "export #{typescript_keyword} #{name} = #{typescript_value}"
          else
            typescript_value
          end
        end

        def typescript_keyword
          "type"
        end

        def typescript_value
          raise NotImplementedError
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'dry-initializer'

module Dry
  module Typescript
    module Types
      class Type
        extend Dry::Initializer

        option :name, optional: true

        def to_typescript(name_override=nil)
          name = name_override || self.name

          if !name.nil?
            "export type #{name} = #{typescript_value}"
          else
            typescript_value
          end
        end

        def typescript_value
          raise NotImplementedError
        end
      end
    end
  end
end

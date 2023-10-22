# frozen_string_literal: true

require_relative './type'
require_relative './union'

module Dry
  module Typescript
    module Types
      class Array < Type
        option :type, optional: true

        def typescript_value
          "Array<#{type.typescript_value}>"
        end
      end
    end
  end
end

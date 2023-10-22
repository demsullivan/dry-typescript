# frozen_string_literal: true

require_relative "./type"
require_relative "./union"

module Dry
  module Typescript
    module TsTypes
      class Array < Type
        attribute? :type, DryTypes.Instance(TsTypes::Type).optional

        def typescript_value
          "Array<#{type.typescript_value}>"
        end
      end
    end
  end
end

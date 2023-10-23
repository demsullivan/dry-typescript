# frozen_string_literal: true

require_relative "./type"
require_relative "./union"

module Dry
  module Typescript
    module TsTypes
      class Array < Type
        attribute? :type, DryTypes.Instance(TsTypes::Type).optional

        def with_transformed_types
          new_type = yield self.type
          self.class.new(name: name, type: new_type)
        end

        def transform_types
          self[:type] = yield self.type
        end

        def typescript_value
          "Array<#{type.typescript_value}>"
        end
      end
    end
  end
end

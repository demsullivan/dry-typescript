# frozen_string_literal: true

require_relative './type'

module Dry
  module Typescript
    module TsTypes
      class Reference < Type
        def to_typescript(name_override = nil)
          name_override || typescript_value
        end

        def typescript_value
          name
        end
      end
    end
  end
end

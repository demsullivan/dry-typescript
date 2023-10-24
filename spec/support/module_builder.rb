# frozen_string_literal: true

module ModuleBuilder

  def ts_namespace(**definitions)
    definitions
  end

  def module_double(**definitions)
    mod = Module.new do
      extend Dry::Typescript
    end

    definitions.each do |name, value|
      mod.ts_export mod.const_set(name.to_sym, value)
    end
  end
end

RSpec.configure do |config|
  config.include ModuleBuilder
end

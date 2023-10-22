# frozen_string_literal: true

module ModuleBuilder
  def module_double(**definitions)
    mod = Module.new
    definitions.each do |name, value|
      mod.const_set(name.to_sym, value)
    end

    mod
  end
end

RSpec.configure do |config|
  config.include ModuleBuilder
end

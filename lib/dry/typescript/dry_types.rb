# frozen_string_literal: true

require "dry-types"

module Dry::Typescript::DryTypes
  include Dry.Types()
  extend Dry::Typescript

  TypeOptions = Hash.schema(
    ignore: Bool.default(false),
  )
end

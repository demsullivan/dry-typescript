# frozen_string_literal: true

require 'dry-typescript'

T = Dry::Typescript::DryTypes

module OtherTest
  extend Dry::Typescript

  ts_export MyArray = T::Array.of(T::String)
end

module TestModule
  extend Dry::Typescript

  # ts_export_all: exports all constants from this module
  # ts_include:    includes all constants from another module

  ts_export UUID  = T::String.ts_alias('UUID')
  ts_export Email = T::String.ts_alias('Email')
  ts_export User  = T::Hash.schema(id: UUID, email: Email, arr: OtherTest::MyArray)
end

RSpec.describe "Module extensions" do
  describe ".ts_export" do
    it "generates type definitions" do
      expect(Dry::Typescript.export.join(";\n")).to eq(<<~TYPESCRIPT.strip)
        export type MyArray = Array<string>;
        export type UUID = string;
        export type Email = string;
        export type User = {
          id: UUID
          email: Email
          arr: MyArray
        }
      TYPESCRIPT
    end
  end
end

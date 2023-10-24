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

  describe "single module extension" do
    let(:mod) do
      mod = Module.new do
        extend Dry::Typescript
      end

      mod::UUID  = Dry::Typescript::DryTypes::String.ts('UUID')
      mod::Email = Dry::Typescript::DryTypes::String.ts('Email')
      mod::User  = Dry::Typescript::DryTypes::Hash.schema(id: mod::UUID, email: mod::Email)

      mod
    end

    describe "#to_typescript" do
      it "generates a type definition" do
        expect(mod.to_typescript.join(";\n")).to eq(<<~TYPESCRIPT.strip)
          export type UUID = string;
          export type Email = string;
          export type User = {
            id: UUID
            email: Email
          }
        TYPESCRIPT
      end
    end
  end
end

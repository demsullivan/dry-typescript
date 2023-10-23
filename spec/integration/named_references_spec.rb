# frozen_string_literal: true

require 'spec_helper'
require 'dry/typescript/compiler'
require 'dry/typescript/dry_types'

RSpec.describe "Named references" do
  subject { Dry::Typescript::Compiler.new(types_module) }

  describe "multiple type aliases of the same type without manual alias" do
    let(:types_module) do
      Module.new.tap do |mod|
        mod::UUID  = Dry::Typescript::DryTypes::String
        mod::Email = Dry::Typescript::DryTypes::String
        mod::User  = Dry::Typescript::DryTypes::Hash.schema(id: mod::UUID, email: mod::Email)
      end
    end

    it "flags duplicate type values"
  end

  describe "multiple type aliases of the same type with manual alias" do
    let(:types_module) do
      Module.new.tap do |mod|
        mod::UUID  = Dry::Typescript::DryTypes::String.ts('UUID')
        mod::Email = Dry::Typescript::DryTypes::String.ts('Email')
        mod::User  = Dry::Typescript::DryTypes::Hash.schema(id: mod::UUID, email: mod::Email)
      end
    end

    it "does not flag duplicate type values"

    it "generates a type definition" do
      expect(subject.compile.join(";\n")).to include(<<~TYPESCRIPT.strip)
        export type UUID = string;
        export type Email = string;
        export type User = {
          id: UUID
          email: Email
        }
      TYPESCRIPT
    end
  end


  describe "in an array, without a manual alias" do
    let(:types_module) do
      Module.new.tap do |mod|
        mod::User  = Dry::Typescript::DryTypes::Hash.schema(name: Dry::Typescript::DryTypes::String)
        mod::Users = Dry::Typescript::DryTypes::Array.of(mod::User)
      end
    end

    it "generates a type definition" do
      expect(subject.compile.join("\n")).to eq(<<~TYPESCRIPT.strip)
        export type User = {
          name: string
        }
        export type Users = Array<User>
      TYPESCRIPT
    end
  end

  describe "in an array, with a manual alias" do
    let(:types_module) do
      Module.new.tap do |mod|
        mod::User  = Dry::Typescript::DryTypes::Hash.schema(name: Dry::Typescript::DryTypes::String).ts('MyUser')
        mod::Users = Dry::Typescript::DryTypes::Array.of(mod::User)
      end
    end

    it "generates a type definition" do
      expect(subject.compile.join("\n")).to include(<<~TYPESCRIPT.strip)
        export type MyUser = {
          name: string
        }
        export type Users = Array<MyUser>
      TYPESCRIPT
    end
  end
end

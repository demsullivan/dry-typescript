# frozen_string_literal: true

require 'spec_helper'
require 'dry/typescript/compiler'
require 'dry/typescript/dry_types'

RSpec.describe "Named references" do
  subject { Dry::Typescript::Compiler.new(Dry::Typescript::Namespace) }

  after(:each) { Dry::Typescript::Namespace.clear! }

  describe "multiple type aliases of the same type without manual alias" do
    let!(:type_module) do
      Module.new do
        extend Dry::Typescript

        ts_export self::UUID  = Dry::Typescript::DryTypes::String
        ts_export self::Email = Dry::Typescript::DryTypes::String
        ts_export self::User  = Dry::Typescript::DryTypes::Hash.schema(id: self::UUID, email: self::Email)
      end
    end

    it "flags duplicate type values" do
      expect(Warning).to receive(:warn).with(/Duplicate types found/).at_least(:once)
      subject.compile
    end

    it "generates a type definition using the last named reference" do
      allow(Warning).to receive(:warn) # patch Warning to clean up rspec output
      expect(subject.compile.join(";\n")).to include(<<~TYPESCRIPT.strip)
        export type UUID = string;
        export type Email = string;
        export type User = {
          id: Email
          email: Email
        }
      TYPESCRIPT
    end
  end

  describe "multiple type aliases of the same type with manual alias" do
    let!(:type_module) do
      Module.new do
        extend Dry::Typescript

        # assigning constants within a Module.new block doesn't actually assign them
        # to the module for some reason, so we have to prefix them with self::
        ts_export self::UUID  = Dry::Typescript::DryTypes::String.ts_alias('UUID')
        ts_export self::Email = Dry::Typescript::DryTypes::String.ts_alias('Email')
        ts_export self::User  = Dry::Typescript::DryTypes::Hash.schema(id: self::UUID, email: self::Email)
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
    let!(:type_module) do
      Module.new do
        extend Dry::Typescript

        ts_export self::User  = Dry::Typescript::DryTypes::Hash.schema(name: Dry::Typescript::DryTypes::String)
        ts_export self::Users = Dry::Typescript::DryTypes::Array.of(self::User)
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
    let!(:type_module) do
      Module.new do
        extend Dry::Typescript

        ts_export self::User  = Dry::Typescript::DryTypes::Hash.schema(name: Dry::Typescript::DryTypes::String).ts_alias('MyUser')
        ts_export self::Users = Dry::Typescript::DryTypes::Array.of(self::User)
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

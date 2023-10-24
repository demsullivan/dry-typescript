# frozen_string_literal: true

require 'dry-typescript'

T = Dry::Typescript::DryTypes

RSpec.describe "Module extensions" do
  after(:each) { Dry::Typescript::Namespace.clear! }

  describe ".ts_export" do
    before(:each) do
      A = Module.new do
        extend Dry::Typescript
        ts_export self::MyArray = T::Array.of(T::String)
      end

      Module.new do
        extend Dry::Typescript
        ts_export self::UUID  = T::String.ts_alias('UUID')
        ts_export self::Email = T::String.ts_alias('Email')
        ts_export self::User  = T::Hash.schema(id: self::UUID, email: self::Email, arr: A::MyArray)
      end
    end

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

  describe ".ts_export_all" do
    shared_examples_for "it exports all types" do
      it "generates type definitions" do
        expect(Dry::Typescript.export.join(";\n")).to eq(<<~TYPESCRIPT.strip)
        export type UUID = string;
        export type Email = string;
        export type User = {
          id: UUID
          email: Email
        }
      TYPESCRIPT
      end
    end

    context "without a parameter" do
      before(:each) do
        Module.new do
          extend Dry::Typescript
          ts_export_all

          self::UUID = T::String.ts_alias('UUID')
          self::Email = T::String.ts_alias('Email')
          self::User = T::Hash.schema(id: self::UUID, email: self::Email)
        end
      end

      it_behaves_like "it exports all types"
    end

    context "with a parameter" do
      before(:each) do
        WithParameter = Module.new do
          self::UUID = T::String.ts_alias('UUID')
          self::Email = T::String.ts_alias('Email')
          self::User = T::Hash.schema(id: self::UUID, email: self::Email)
        end

        Module.new do
          extend Dry::Typescript
          ts_export_all WithParameter
        end
      end

      it_behaves_like "it exports all types"
    end

  end
end

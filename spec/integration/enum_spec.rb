# frozen_string_literal: true

require "spec_helper"
require "dry/typescript/compiler"
require "dry/typescript/ts_types/enum"

RSpec.describe "Enums" do
  subject { Dry::Typescript::Compiler.new(namespace) }

  describe "string enums" do
    describe "a simple enum" do
      let(:namespace) { ts_namespace(SimpleEnum: Dry::Typescript::DryTypes::String.enum("a", "b")) }

      it "generates a type definition" do
        expect(subject.compile).to include(<<~TYPESCRIPT)
          export enum SimpleEnum {
            A = "a",
            B = "b"
          }
        TYPESCRIPT
      end
    end

    describe "an enum with names" do
      let(:namespace) { ts_namespace(NamedEnum: Dry::Typescript::DryTypes::String.enum(foo: "BAR", bar: "BAZ")) }

      it "generates a type definition" do
        expect(subject.compile).to include(<<~TYPESCRIPT)
          export enum NamedEnum {
            FOO = "BAR",
            BAR = "BAZ"
          }
        TYPESCRIPT
      end
    end
  end

  describe "integer enums" do
    describe "without key names" do
      let(:namespace) { ts_namespace(SimpleEnum: Dry::Typescript::DryTypes::Integer.enum(1, 2)) }

      it "raises an InvalidEnumError" do
        expect { subject.compile }.to raise_error(Dry::Typescript::TsTypes::Enum::InvalidEnumError)
      end
    end

    describe "with key names" do
      let(:namespace) { ts_namespace(NamedEnum: Dry::Typescript::DryTypes::Integer.enum(foo: 1, bar: 2)) }

      it "generates a type definition" do
        expect(subject.compile).to include(<<~TYPESCRIPT)
          export enum NamedEnum {
            FOO = 1,
            BAR = 2
          }
        TYPESCRIPT
      end
    end
  end
end

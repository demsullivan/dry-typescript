# frozen_string_literal: true

require 'spec_helper'
require 'dry/typescript/compiler'
require 'dry/typescript/types/enum'

RSpec.describe "Enums" do
  describe "string enums" do
    describe "a simple enum" do
      let(:types_module) { module_double(SimpleEnum: Types::String.enum("a", "b")) }

      subject { Dry::Typescript::Compiler.new(types_module) }

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
      let(:types_module) { module_double(NamedEnum: Types::String.enum(foo: "BAR", bar: "BAZ")) }

      subject { Dry::Typescript::Compiler.new(types_module) }

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
      let(:types_module) { module_double(SimpleEnum: Types::Integer.enum(1, 2)) }

      subject { Dry::Typescript::Compiler.new(types_module) }

      it "raises an InvalidEnumError" do
        expect { subject.compile }.to raise_error(Dry::Typescript::Types::Enum::InvalidEnumError)
      end
    end

    describe "with key names" do
      let(:types_module) { module_double(NamedEnum: Types::Integer.enum(foo: 1, bar: 2)) }

      subject { Dry::Typescript::Compiler.new(types_module) }

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
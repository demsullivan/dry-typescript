# frozen_string_literal: true

require "spec_helper"

require "dry-struct"
require "dry/typescript/compiler"

RSpec.describe "Structs" do
  subject { Dry::Typescript::Compiler.new(types_module) }

  describe "with a single required attribute" do
    let(:struct) do
      Class.new(Dry::Struct) do
        attribute :a, Dry::Typescript::DryTypes::String
      end
    end

    let(:types_module) { module_double(SimpleStruct: struct) }

    it "generates a type definition" do
      expect(subject.compile).to include("export interface SimpleStruct = {\n  a: string\n}")
    end
  end

  describe "with a single optional attribute" do
    let(:struct) do
      Class.new(Dry::Struct) do
        attribute? :a, Dry::Typescript::DryTypes::String
      end
    end

    let(:types_module) { module_double(SimpleStruct: struct) }

    it "generates a type definition" do
      expect(subject.compile).to include("export interface SimpleStruct = {\n  a?: string\n}")
    end
  end

  describe "nested attributes" do
    let(:struct) do
      Class.new(Dry::Struct) do
        attribute :nested do
          attribute :a, Dry::Typescript::DryTypes::String
        end
        attribute :b, Dry::Typescript::DryTypes::String
      end
    end

    let(:types_module) { module_double(NestedStruct: struct) }

    it "generates a type definition" do
      expect(subject.compile).to include("export interface NestedStruct = {\n  nested: {\n  a: string\n}\n  b: string\n}")
    end
  end
end

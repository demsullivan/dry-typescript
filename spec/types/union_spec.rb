# frozen_string_literal: true

require "spec_helper"

require "dry/typescript/compiler"

RSpec.describe "Unions" do
  subject { Dry::Typescript::Compiler.new(types_module) }

  describe "a simple union" do
    let(:types_module) { module_double(Union: DryTypes::String | DryTypes::Integer) }

    it "generates a type definition" do
      expect(subject.compile).to include("export type Union = string | number")
    end
  end

  describe "a union with a nil type" do
    let(:types_module) { module_double(Union: DryTypes::String | DryTypes::Nil) }

    it "generates a type definition" do
      expect(subject.compile).to include("export type Union = string | null")
    end
  end

  describe "an array with a union" do
    let(:types_module) { module_double(UnionArray: DryTypes::Array.of(DryTypes::String | DryTypes::Integer)) }

    it "generates a type definition" do
      expect(subject.compile).to include("export type UnionArray = Array<string | number>")
    end
  end
end

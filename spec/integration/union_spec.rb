# frozen_string_literal: true

require "spec_helper"

require "dry/typescript/compiler"

RSpec.describe "Unions" do
  subject { Dry::Typescript::Compiler.new(namespace) }

  describe "a simple union" do
    let(:namespace) { ts_namespace(Union: Dry::Typescript::DryTypes::String | Dry::Typescript::DryTypes::Integer) }

    it "generates a type definition" do
      expect(subject.compile).to include("export type Union = string | number")
    end
  end

  describe "a union with a nil type" do
    let(:namespace) { ts_namespace(Union: Dry::Typescript::DryTypes::String | Dry::Typescript::DryTypes::Nil) }

    it "generates a type definition" do
      expect(subject.compile).to include("export type Union = string | null")
    end
  end

  describe "an array with a union" do
    let(:namespace) { ts_namespace(UnionArray: Dry::Typescript::DryTypes::Array.of(Dry::Typescript::DryTypes::String | Dry::Typescript::DryTypes::Integer)) }

    it "generates a type definition" do
      expect(subject.compile).to include("export type UnionArray = Array<string | number>")
    end
  end
end

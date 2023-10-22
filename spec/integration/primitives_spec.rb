# frozen_string_literal: true

require "spec_helper"

require "dry/typescript/compiler"

RSpec.describe "Primitives" do
  subject { Dry::Typescript::Compiler.new(types_module) }

  shared_examples_for "a primitive type" do |dry_types, type_name, type_def|
    describe "for Types::#{type_name}" do
      let(:types_module) { module_double(type_name => dry_types.const_get(type_name)) }

      it "generates a type definition" do
        expect(subject.compile).to include("export type #{type_name} = #{type_def}")
      end

      context "with .optional" do
        let(:types_module) { module_double(type_name => dry_types.const_get(type_name).optional) }

        it "generates a union type definition with null" do
          expect(subject.compile).to include("export type #{type_name} = #{type_def} | null")
        end
      end

      context "in an array" do
        let(:types_module) { module_double("#{type_name}Array" => dry_types::Array.of(dry_types.const_get(type_name))) }

        it "generates a type definition" do
          expect(subject.compile).to include("export type #{type_name}Array = Array<#{type_def}>")
        end
      end
    end
  end

  describe "Types::Nil" do
    let(:types_module) { module_double(Nil: Dry::Typescript::DryTypes::Nil) }

    it "generates a type definition" do
      expect(subject.compile).to include("export type Nil = null")
    end

    context "with .optional" do
      let(:types_module) { module_double(Nil: Dry::Typescript::DryTypes::Nil.optional) }

      it "generates a union type definition with null" do
        expect(subject.compile).to include("export type Nil = null")
      end
    end
  end

  describe "Types::Array" do
    let(:types_module) { module_double(MyArray: Dry::Typescript::DryTypes::Array) }

    it "generates a type definition" do
      expect(subject.compile).to include("export type MyArray = Array<any>")
    end

    context "with .optional" do
      let(:types_module) { module_double(OptionalArray: Dry::Typescript::DryTypes::Array.optional) }

      it "generates a union type definition with null" do
        expect(subject.compile).to include("export type OptionalArray = Array<any> | null")
      end
    end
  end

  {
    Any: "any",
    Symbol: "string",
    Class: "any",
    True: "boolean",
    False: "boolean",
    Bool: "boolean",
    Integer: "number",
    Float: "number",
    Decimal: "number",
    String: "string",
    Date: "string",
    DateTime: "string",
    Time: "string"
  }.each do |type_name, type_def|
    describe "Types::Strict::#{type_name}" do
      it_behaves_like "a primitive type", Dry::Typescript::DryTypes::Strict, type_name, type_def
    end

    describe "Types::Nominal::#{type_name}" do
      it_behaves_like "a primitive type", Dry::Typescript::DryTypes::Nominal, type_name, type_def
    end
  end
end

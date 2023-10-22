# frozen_string_literal: true

require 'spec_helper'

require 'dry/typescript/compiler'

Types = Dry::Typescript::Types

RSpec.describe "Primitives" do

  subject { Dry::Typescript::Compiler.new(types_module) }

  shared_examples_for "a primitive type" do |type, type_name, type_def|
    describe "for Types::#{type_name}" do
      let(:types_module) { module_double(type_name => type) }

      it "generates a type definition" do
        expect(subject.compile).to include("export type #{type_name} = #{type_def}")
      end

      context "with .optional" do
        let(:types_module) { module_double(type_name => type.optional) }

        it "generates a union type definition with null" do
          expect(subject.compile).to include("export type #{type_name} = #{type_def} | null")
        end
      end
    end
  end

  it_behaves_like "a primitive type", Types::String,  :String,  "string"
  it_behaves_like "a primitive type", Types::Integer, :Integer, "number"
  it_behaves_like "a primitive type", Types::Decimal, :Decimal, "number"
  it_behaves_like "a primitive type", Types::Bool,    :Bool,    "boolean"
end
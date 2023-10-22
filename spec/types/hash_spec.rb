# frozen_string_literal: true

require "spec_helper"

require "dry/typescript/compiler"

RSpec.describe "Hashes" do
  subject { Dry::Typescript::Compiler.new(types_module) }

  describe "a simple hash" do
    let(:types_module) { module_double(Hash: DryTypes::Hash) }

    it "generates a type definition" do
      expect(subject.compile).to include(<<~TYPESCRIPT)
        export type Hash = { [key: any]: any }
      TYPESCRIPT
    end
  end

  describe "a hash with an empty schema" do
    let(:types_module) { module_double(EmptySchema: DryTypes::Hash.schema({})) }

    it "generates a type definition" do
      expect(subject.compile).to include(<<~TYPESCRIPT)
        export type EmptySchema = { [key: any]: any }
      TYPESCRIPT
    end
  end

  describe "a hash with a schema" do
    let(:types_module) { module_double(SimpleHash: DryTypes::Hash.schema(a: DryTypes::String)) }

    it "generates a type definition" do
      expect(subject.compile).to include(<<~TYPESCRIPT)
        export type SimpleHash = {
          a: string
        }
      TYPESCRIPT
    end
  end
end

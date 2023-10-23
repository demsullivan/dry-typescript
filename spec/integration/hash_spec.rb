# frozen_string_literal: true

require "spec_helper"

require "dry/typescript/compiler"

RSpec.describe "Hashes" do
  subject { Dry::Typescript::Compiler.new(types_module) }

  def self.test_with_types(dry_types)
    describe "with #{dry_types}" do
      describe "a simple hash" do
        let(:types_module) { module_double(Hash: dry_types::Hash) }

        it "generates a type definition" do
          expect(subject.compile).to include("export type Hash = { [key: any]: any }")
        end
      end

      describe "a hash with an empty schema" do
        let(:types_module) { module_double(EmptySchema: dry_types::Hash.schema({})) }

        it "generates a type definition" do
          expect(subject.compile).to include("export type EmptySchema = { [key: any]: any }")
        end
      end

      describe "a hash with a schema" do
        let(:types_module) { module_double(SimpleHash: dry_types::Hash.schema(a: Dry::Typescript::DryTypes::String)) }

        it "generates a type definition" do
          expect(subject.compile).to include("export type SimpleHash = {\n  a: string\n}")
        end
      end
    end
  end

  test_with_types(Dry::Typescript::DryTypes::Strict)
  test_with_types(Dry::Typescript::DryTypes::Nominal)
end

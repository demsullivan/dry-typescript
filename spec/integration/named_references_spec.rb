# frozen_string_literal: true

require 'spec_helper'
require 'dry/typescript/compiler'
require 'dry/typescript/dry_types'

RSpec.describe "Named references" do
  subject { Dry::Typescript::Compiler.new(types_module) }

  describe "multiple type aliases of the same type" do
    let(:types_module) do
      module Test
        include Dry.Types()
        UUID  = Dry::Typescript::DryTypes::String.ts('UUID')
        Email = Dry::Typescript::DryTypes::String.ts('Email')
        User  = Dry::Typescript::DryTypes::Hash.schema(id: UUID, email: Email)
      end

      Test
    end

    it "generates a type definition" do
      expect(subject.compile).to include(<<~TYPESCRIPT)
        export type UUID = string;
        export type Email = string;
        export type User = {
          id: UUID,
          email: Email
        }
      TYPESCRIPT
    end
  end

  describe "in an array" do
    let(:types_module) do
      module Test
        User  = Dry::Typescript::DryTypes::Hash.schema(name: Dry::Typescript::DryTypes::String).ts('User')
        Users = Dry::Typescript::DryTypes::Array.of(User)
      end

      Test
    end

    it "generates a type definition" do
      expect(subject.compile).to include(<<~TYPESCRIPT)
        export type User = {
          name: string
        }
        export type Users = Array<User>
      TYPESCRIPT
    end
  end
end

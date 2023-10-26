# frozen_string_literal: true

require 'dry-typescript'

T = Dry::Typescript::DryTypes

RSpec.describe "Module extensions" do
  subject { Dry::Typescript.export.join(";\n") }

  after(:each) { Dry::Typescript::Namespace.clear }

  shared_examples_for "it exports the correct type definitions" do
    it "generates type definitions" do
      expect(subject).to eq(<<~TYPESCRIPT.strip)
        export type UUID = string;
        export type Email = string;
        export type User = {
          id: UUID
          email: Email
        };
        export type Users = Array<User>
      TYPESCRIPT
    end
  end

  describe "type exports" do
    describe "with all types exported" do
      before(:each) do
        Module.new do
          extend Dry::Typescript

          ts_export self::UUID  = T::String
          ts_export self::Email = T::String
          ts_export self::User  = T::Hash.schema(id: self::UUID, email: self::Email)
          ts_export self::Users = T::Array.of(self::User)

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"
    end

    describe "with only some types exported and no dependencies" do
      before(:each) do
        Module.new do
          extend Dry::Typescript

          self::Blah = T::Integer
          ts_export self::UUID  = T::String
          ts_export self::Email = T::String
          ts_export self::User  = T::Hash.schema(id: self::UUID, email: self::Email)
          ts_export self::Users = T::Array.of(self::User)

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"
    end

    describe "with only some types exported, and dependencies on unexported types" do
      before(:each) do
        Module.new do
          extend Dry::Typescript

          self::UUID  = T::String
          self::Email = T::String
          ts_export self::User  = T::Hash.schema(id: self::UUID, email: self::Email)
          ts_export self::Users = T::Array.of(self::User)

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"

      it "warns about references to unexported types" do
        expect(Warning).to receive(:warn).with(/Found reference to unexported constant (.*)::UUID/)
        expect(Warning).to receive(:warn).with(/Found reference to unexported constant (.*)::Email/)
      end
    end

    describe "with dependencies on external modules that extend dry-typescript" do
      before(:each) do
        ModA = Module.new do
          extend Dry::Typescript

          ts_export self::UUID  = T::String
          ts_export self::Email = T::String

          finalize_ts_exports!
        end

        Module.new do
          extend Dry::Typescript

          ts_export self::User = T::Hash.schema(id: ModA::UUID, email: ModA::Email)
          ts_export self::Users = T::Array.of(self::User)

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"
    end

    describe "with dependencies on external modules that extend dry-typescript, with their own unexported deps" do
      before(:each) do
        ModA = Module.new do
          extend Dry::Typescript

          self::UUID  = T::String
          self::Email = T::String
          ts_export self::User = T::Hash.schema(id: self::UUID, email: self::Email)

          finalize_ts_exports!
        end

        Module.new do
          extend Dry::Typescript

          ts_export self::Users = T::Array.of(ModA::User)

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"

      it "warns about references to unexported types" do
        expect(Warning).to receive(:warn).with(/Found reference to unexported constant (.*)::UUID/)
        expect(Warning).to receive(:warn).with(/Found reference to unexported constant (.*)::Email/)
      end
    end

    describe "with dependencies on external modules that DO NOT extend dry-typescript" do
      before(:each) do
        ModA = Module.new do
          self::UUID  = T::String
          self::Email = T::String
        end

        Module.new do
          extend Dry::Typescript

          # Problem: UUID and Email are already defined, so we don't have an opportunity
          # to alias them before they get referenced here, which means UUID and Email
          # aren't exported and the types of the hash keys are 'string'.
          ts_export self::User = T::Hash.schema(id: ModA::UUID, email: ModA::Email)
          ts_export self::Users = T::Array.of(self::User)

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"
    end

    describe "with dependencies on external modules that DO NOT extend dry-typescript, with their own dependencies" do
      before(:each) do
        ModA = Module.new do
          self::UUID  = T::String
          self::Email = T::String
          self::User = T::Hash.schema(id: self::UUID, email: self::Email)
        end

        Module.new do
          extend Dry::Typescript

          # Same problem as above: the constants in ModA are already defined, so
          # we never have a chance to alias them properly. This means that UUID, Email
          # and User don't get exported, and instead Users is exported as an array of
          # { id: string, email: string }.
          ts_export self::Users = T::Array.of(ModA::User)

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"
    end

    describe "with an export module that is simply exporting the contents of other modules" do
      before(:each) do
        ModA = Module.new do
          self::UUID  = T::String
          self::Email = T::String
          self::User  = T::Hash.schema(id: self::UUID, email: self::Email)
          self::Users = T::Array.of(self::User)
        end

        Module.new do
          extend Dry::Typescript

          # Since the references to UUID and Email from User, and to User from Users,
          # are already defined, we don't have an opportunity to alias them properly.
          # Exports:
          # export type UUID = string;
          # export type Email = string;
          # export type User = {
          #   id: string
          #  email: string
          # };
          # export type Users = Array<{
          #  id: string
          #  email: string
          # }>;
          ts_export self::UUID  = ModA::UUID
          ts_export self::Email = ModA::Email
          ts_export self::User  = ModA::User
          ts_export self::Users = ModA::Users

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"
    end

    describe "with an export module that exports the partial contents of another module" do
      before(:each) do
        ModA = Module.new do
          self::UUID  = T::String
          self::Email = T::String
          self::User  = T::Hash.schema(id: self::UUID, email: self::Email)
          self::Users = T::Array.of(self::User)
        end

        Module.new do
          extend Dry::Typescript

          # Ditto previous.
          ts_export self::User  = ModA::User
          ts_export self::Users = ModA::Users

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"
    end
  end


  describe "module exports" do
    describe "simple module export" do
      before(:each) do
        WithParameter = Module.new do
          self::UUID = T::String
          self::Email = T::String
          self::User = T::Hash.schema(id: self::UUID, email: self::Email)
          self::Users = T::Array.of(self::User)
        end

        Module.new do
          extend Dry::Typescript

          # Ditto previous.
          ts_export WithParameter

          finalize_ts_exports!
        end
      end

      it_behaves_like "it exports the correct type definitions"
    end
  end
end

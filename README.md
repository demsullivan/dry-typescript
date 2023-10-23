# Dry::Typescript

> [!WARNING]
> This gem is currently in pre-release and is not yet intended for production use cases. As such,
> it has not been published to rubygems.

This gem provides a simple way to generate Typescript type definitions from [dry-types](https://dry-rb.org/gems/dry-types/1.7/)
and [dry-struct](https://dry-rb.org/gems/dry-struct/1.6/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-typescript',
    git: "https://github.com/demsullivan/dry-typescript",
    branch: "0.1.0-pre1"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dry-typescript

## Usage

Further instructions coming soon!

Check out the specs for examples of supported types and use cases, or see below for a quick example.

Given a Ruby file with the following contents:

```ruby
require 'dry-types'
require 'dry-struct'
require 'dry/typescript'

module Types
  include Dry.Types()

  StringedArray    = Types::Array.of(Types::String)
  StringOrIntArray = Types::Array.of(Types::String | Types::Integer)
  NeatHash         = Types::Hash.schema(
    name: Types::String,
    age: Types::Integer.optional,
  )
end

class Types::MyStruct < Dry::Struct
  attribute :name, Types::String
  attribute :nullable, Types::String.optional
  attribute? :optional, Types::String
  attribute :address do
    attribute :street, Types::String
    attribute :city, Types::String
    attribute :state, Types::String
  end
end

module Types::Export
  extend Dry::Typescript
  
  StringedArray    = Types::StringedArray
  StringOrIntArray = Types::StringOrIntArray
  MyStruct         = Types::MyStruct
  NeatHash         = Types::NeatHash
end
```

You can run the dry-typescript compiler like so:

```ruby
Types::Export.to_typescript(filename: 'path/to/types.d.ts')
```

Which will generate a file with the following contents:

```typescript
export type StringedArray = Array<string>;
export type StringOrIntArray = Array<string | number>;

export type NeatHash = {
  name: string;
  age: number | null;
}

export interface MyStruct {
  name: string;
  nullable: string | null;
  optional?: string;
  address: {
    street: string;
    city: string;
    state: string;
  }
}
```

## Supported Types

- All built-in strict and nominal types from dry-types, see: https://dry-rb.org/gems/dry-types/1.7/built-in-types/
- Hashes with schemas, exported as Typescript types
- `Dry::Struct`, including nested attributes, exported as Typescript interfaces
- dry-types Sums, exported as Typescript unions
- Arrays, including typed arrays

## Development

After checking out the repo, run `bundle install` to install dependencies. 
Then, run `bundle exec rspec` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, 
which will create a git tag for the version, push git commits and the created tag, and push the `.gem` 
file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/demsullivan/dry-typescript.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

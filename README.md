# Dry::Typescript


Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/dry/typescript`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-typescript'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dry-typescript

## Usage

TODO: Write usage instructions here

## Supported Types

- Common primitives, eg. `String`, `Integer`, `Decimal`, `Bool`
- Hashes with schemas, defined as Typescript types by default
- Dry::Struct, including nested attributes, defined as Typescript interfaces by default
- Sums / Unions
- Arrays

## TODO

- [ ] Resolving references
- [ ] Support for interface inheritance
- [ ] Option to instruct compiler to ignore a type
- [ ] Validating Typescript reserved words

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dry-typescript.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# Generators

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/generators`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'generators', github: 'ikkiuchi/generators'
end
```

And then execute:

    $ bundle


## Usage

See: [Zero Rails](https://github.com/zhandao/zero-rails/tree/master/app/_docs)

    $ vi app/_docs/model_docs/[your_model_name]_mdoc.rb

MDoc (model doc) will generate: Model, Migration, Factory, Model Spec, ApiDoc(if g(version)).

ApiDoc will generate (if g()): Controller, Jbuilder Views, Request SpecDoc, BizError.

SpDoc (spec doc) will generate: Request / Normal / Model Spec.

**Remember to check the generated files.**

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/generators. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Generators project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/generators/blob/master/CODE_OF_CONDUCT.md).

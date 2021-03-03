# PurpleAirApi

This is a client for interacting with the PurpleAir API. This was written using the V1 of the API. In order to use this gem, you must have been granted read and write tokens from PurpleAir.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'purple_air_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install purple_air_api

## Usage

To use this gem, instantiate an instance of a PurpleAirApi client by making the following request:

`client = PurpleAirApi.client(read_token: your_read_token, write_token: your_write_token)`

You can then use this client to interact with the various API methods under the client like:

`client.get_sensors(options)` 

Options would be and of the parameters you would like to pass onto the PurpleAir API. The gem will parse the parameters into the format required by the API.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dkiselbach/purple_air_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dkiselbach/purple_air_api/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PurpleAirApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dkiselbach/purple_air_api/CODE_OF_CONDUCT.md).

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](code_of_conduct.md)

# PurpleAirApi
This is a Ruby wrapper for the PurpleAir API.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'purple_air_api'
```

And then execute:

`bundle install`

Or install it yourself as:

`gem install purple_air_api`

## Usage
To use this gem, instantiate an instance of a PurpleAirApi client. The write token is
optional and currently no write actions are implemented in this gem.

`client = PurpleAirApi.client(read_token: your_read_token, write_token: your_write_token)`

You can then use this client to interact with the various API methods under the client:

### Requesting multiple sensors 
```ruby
# Optional parameters are added using a hash. For a full list of options refer to the documentation.

nw_lat_long = [37.804930, -122.448382]
se_lat_long = [37.794832, -122.393589]
fields = %w[icon name latitude longitude altitude pm2.5 pm2.5_10minute pm2.5_30minute pm2.5_60minute]
location_type = %w[outside]
show_only = [20, 40, 55, 120]

options = {
  fields: fields,
  location_type: location_type,
  bounding_box: { nw: nw_lat_long, se: se_lat_long },
  show_only: show_only
}

response = client.request_sensors(options)

response.parsed_response[:data][40] # access the individual sensor data using the parsed_response hash
```

### Requesting a single sensor index
```ruby
response = client.request_sensor(sensor_index: 1)

current_air_quality = response.json_response[:sensor][:"pm2.5_a"]
```

### A sample service object for a lat-long bounding box
```ruby
# frozen_string_literal: true

require 'purple_air_api'
require 'dotenv/load'

module AirQuality
  # Class for making requests for local sensor data with a lat-long bounding box
  class GetSensors
    NW_LAT_LONG = [37.804930, -122.448382].freeze
    SE_LAT_LONG = [37.794832, -122.393589].freeze
    DEFAULT_FIELDS = %w[icon name latitude longitude altitude pm2.5 pm2.5_10minute pm2.5_30minute pm2.5_60minute].freeze
    DEFAULT_LOCATION_TYPE = %w[outside].freeze

    def self.call
      new.request
    end

    def request
      PurpleAirApi.client(read_token: read_token).request_sensors(fields)
    end

    def read_token
      ENV['READ_TOKEN']
    end

    def fields
      {
        fields: DEFAULT_FIELDS,
        location_type: DEFAULT_LOCATION_TYPE,
        bounding_box: { nw: NW_LAT_LONG, se: SE_LAT_LONG }
      }
    end
  end
end
````

### A sample service object for a single sensor
```ruby
# frozen_string_literal: true

require 'purple_air_api'
require 'dotenv/load'

module AirQuality
  # Class for making requests for an individual sensor
  class GetSensor
    SENSOR_INDEX = 54_849

    def self.call
      new.request
    end

    def request
      PurpleAirApi.client(read_token: read_token).request_sensor(sensor_index: SENSOR_INDEX)
    end

    def read_token
      ENV['READ_TOKEN']
    end
  end
end
```

### In a Sinatra app

```ruby
# frozen_string_literal: true

require 'sinatra'
require "sinatra/json"
require 'dotenv/load'
require 'purple_air_api'

module HomeHub
  # App server class for running the HomeHub app
  class App < Sinatra::Base

    get '/sensors/:id' do
      json purple_air_client.request_sensor(sensor_index: params[:id].to_i).json_response
    end

    get '/sensors' do
      json purple_air_client.request_sensors.json_response
    end

    def purple_air_client
      @purple_air_client ||= PurpleAirApi.client(read_token: read_token)
    end

    def read_token
      @read_token ||= ENV['READ_TOKEN']
    end
  end
end
```

## Documentation

Documentation for this gem can be found [here.](https://dkiselbach.github.io/purple_air_api/)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Make sure you are updating the Yard docs prior to pushing to master by running `rake yard`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dkiselbach/purple_air_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dkiselbach/purple_air_api/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PurpleAirApi project's codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dkiselbach/purple_air_api/blob/master/CODE_OF_CONDUCT.md).

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](code_of_conduct.md)

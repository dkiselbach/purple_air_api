# frozen_string_literal: true

module PurpleAirApi
  module V1
    # Class for requesting sensor data. This will return different response formats from the API.
    class GetSensors
      attr_accessor :request_options, :http_response
      attr_reader :http_client
      attr_writer :parsed_response

      # The default value for fields that will be returned by PurpleAir
      DEFAULT_FIELDS = %w[icon name latitude longitude altitude pm2.5].freeze

      # The default location type for the sensor
      DEFAULT_LOCATION_TYPE = %w[outside inside].freeze

      # The endpoint URL
      URL = 'https://api.purpleair.com/v1/sensors'

      # Calls initializes the class and requests the data from PurpleAir.
      # @!method call(...)

      def self.call(...)
        new(...).request
      end

      # Creates a HTTP friendly options hash depending on your inputs
      # @!method initialize(client:, **options)
      # @param client [Faraday::Connection] Your HTTP client initialized in Client
      # @param options [Hash] Your HTTP options for the request.

      def initialize(client:, **options)
        @http_client = client
        @request_options = {}
        create_options_hash(options)
      end

      # Makes a get request to the PurpleAir Get Sensors Data endpoint https://api.purpleair.com/v1/sensors.
      # @!method request
      # @return [PurpleAirApi::V1::GetSensors]

      def request
        self.http_response = http_client.get(URL, request_options)
        self
      end

      # Takes the raw response from PurpleAir and generates a hash indexed by sensor index. You can use this response
      # like a normal hash object. This GetSensorsClass.parsed_response[:47] would return a hash of data for sensor 47
      # with each hash key labelling the associated data.
      # @!method parsed_response
      # @return [Hash]
      # @example parsed_response example
      #   response.parsed_response
      #   {
      #     :fields=>["sensor_index", "name", "icon", "latitude", "longitude", "altitude", "pm2.5"],
      #     :api_version=>"V1.0.6-0.0.9",
      #     :time_stamp=>1614787814,
      #     :data_time_stamp=>nil,
      #     :max_age=>3600,
      #     :data=>
      #     {
      #       20=>{"sensor_index"=>20, "name"=>"Oakdale", "icon"=>0, "latitude"=>40.6031,
      #            "longitude"=>-111.8361, "altitude"=>4636, "pm2.5"=>0.0},
      #       47=>{"sensor_index"=>47, "name"=>"OZONE TEST", "icon"=>0, "latitude"=>40.4762,
      #            "longitude"=>-111.8826, "altitude"=>nil, "pm2.5"=>nil}
      #     }
      #   }

      def parsed_response
        @parsed_response ||= parse_response
      end

      # Takes the raw response from PurpleAir and parses the JSON into a Hash.
      # @!method json_response
      # @return [Hash]
      # @example json_response example
      #   response.json_response
      #   {
      #     :api_version=>"V1.0.6-0.0.9",
      #     :time_stamp=>1614787814,
      #     :data_time_stamp=>1614787807,
      #     :location_type=>0,
      #     :max_age=>3600,
      #     :fields=>["sensor_index", "name", "icon", "latitude", "longitude", "altitude", "pm2.5"],
      #     :data=>[
      #               [20, "Oakdale", 0, 40.6031, -111.8361, 4636, 0.0],
      #               [47, "OZONE TEST", 0, 40.4762, -111.8826, nil, nil]
      #            ]
      #   }

      def json_response
        @json_response ||= FastJsonparser.parse(http_response.body)
      end

      private

      attr_accessor :data, :data_fields

      def create_options_hash(options)
        request_options.merge!(
          fields(options[:fields] || DEFAULT_FIELDS),
          location_type(options[:location_type]),
          show_only(options[:show_only]),
          modified_since(options[:modified_since]),
          max_age(options[:max_age]),
          bounding_box(options[:bounding_box]),
          read_keys(options[:read_keys])
        )
      end

      def fields(fields_array)
        unless fields_array.instance_of?(Array) && fields_array.first.instance_of?(String)
          raise OptionsError, 'fields must be an array of strings specifying the fields you want returned'
        end

        { fields: fields_array.join(',') }
      end

      def show_only(sensor_indices)
        return {} if sensor_indices.nil?

        unless sensor_indices.instance_of?(Array) && sensor_indices.first.instance_of?(Integer)
          raise OptionsError,
                'show_only must be an array of integers specifying the sensor indices you data returned for'
        end

        { show_only: sensor_indices.join(',') }
      end

      def location_type(location_type)
        return {} if location_type.nil?

        location_type_error unless location_type.instance_of?(Array) && location_type.first.instance_of?(String)

        location_type_parameter(location_type.map(&:downcase))
      end

      def location_type_parameter(location_type)
        return {} if location_type.include?('outside') && location_type.include?('inside')
        return { location_type: 1 } if location_type.include?('inside')
        return { location_type: 0 } if location_type.include?('outside')

        location_type_error
      end

      def location_type_error
        raise OptionsError,
              "location_type must be an array of strings specifying either ['inside'], ['outside'], or both"
      end

      def modified_since(timestamp)
        return {} if timestamp.nil?
        raise OptionsError, 'timestamp must be a valid Integer' unless timestamp.instance_of?(Integer)

        { modified_since: timestamp }
      end

      def max_age(seconds)
        return {} if seconds.nil?
        raise OptionsError, 'seconds must be a valid Integer' unless seconds.instance_of?(Integer)

        { max_age: seconds.to_i }
      end

      def bounding_box(coordinates)
        return {} if coordinates.nil?

        unless coordinates.instance_of?(Hash) && coordinates[:nw].length == 2 && coordinates[:se].length == 2
          raise OptionsError, 'coordinates must be a Hash with a :nw and :se array containing [lat, long]'
        end

        {
          nwlat: coordinates[:nw][0], nwlng: coordinates[:nw][1], selat: coordinates[:se][0], selng: coordinates[:se][1]
        }
      end

      def read_keys(keys)
        return {} if keys.nil?

        unless keys.instance_of?(Array) && keys.first.instance_of?(String)
          raise OptionsError, 'read_keys must be an Array of Strings'
        end

        { read_keys: keys.join(',') }
      end

      def parse_response
        response = json_response

        generate_response_hash(response)

        self.data = response[:data]
        self.data_fields = response[:fields]

        merge_data_hash
      end

      def generate_response_hash(response_hash)
        fields, api_version,
          time_stamp, date_time_stamp, max_age = response_hash.values_at(:fields, :api_version, :time_stamp,
                                                                         :date_time_stamp, :max_age)
        self.parsed_response = {
          fields: fields,
          api_version: api_version,
          time_stamp: time_stamp,
          data_time_stamp: date_time_stamp,
          max_age: max_age
        }
      end

      def merge_data_hash
        parsed_response.merge!({ data: generate_data_hash })
      end

      def generate_data_hash
        data_hash = {}
        data.each do |sensor|
          sensor_index = sensor.first
          data_hash.merge!(sensor_index => {})
          sensor.each_with_index do |data_point, index|
            data_hash[sensor_index].merge!(data_fields[index] => data_point)
          end
        end
        data_hash
      end
    end
  end
end

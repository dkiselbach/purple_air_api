# frozen_string_literal: true

module PurpleAirApi
  module V1
    # Class for requesting sensor from the PurpleAirAPI
    class GetSensors
      attr_accessor :request_options, :parsed_response, :http_response
      attr_reader :http_client

      DEFAULT_FIELDS = %w[icon name latitude longitude altitude pm1.0].freeze
      DEFAULT_LOCATION_TYPE = %w[outside inside].freeze

      URL = 'https://api.purpleair.com/v1/sensors'

      def self.call(...)
        new(...).request
      end

      def initialize(client:, **options)
        @http_client = client
        @request_options = {}
        @parsed_response = {}
        create_options_hash(**options)
      end

      def request
        self.http_response = http_client.get(URL, request_options)
        parse_response(http_response)
        self
      end

      private

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

        unless location_type.instance_of?(Array) && location_type.first.instance_of?(String)
          raise OptionsError,
                "location_type must be an array of strings specifying either ['inside'], ['outside'], or both"
        end

        location_type.map!(&:downcase)

        return {} if location_type.include?('outside') && location_type.include?('inside')
        return { location_type: 1 } if location_type.include?('inside')
        return { location_type: 0 } if location_type.include?('outside')
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
          nwlat: coordinates[:nw][0],
          nwlng: coordinates[:nw][1],
          selat: coordinates[:se][0],
          selng: coordinates[:se][1]
        }
      end

      def read_keys(keys)
        return {} if keys.nil?

        unless keys.instance_of?(Array) && keys.first.instance_of?(String)
          raise OptionsError, 'read_keys must be an Array of Strings'
        end

        { read_keys: keys.join(',') }
      end

      def parse_response(response)
        response_hash = FastJsonparser.parse(response.body)
        fields, data, api_version,
          time_stamp, date_time_stamp, max_age = response_hash.values_at(:fields, :data, :api_version, :time_stamp,
                                                                         :date_time_stamp, :max_age)
        parsed_response.merge!({
                                 fields: fields,
                                 api_version: api_version,
                                 time_stamp: time_stamp,
                                 data_time_stamp: date_time_stamp,
                                 max_age: max_age,
                                 data: {}
                               })
        generate_indexed_hash(data, fields)
      end

      def generate_indexed_hash(data, fields)
        data.each do |sensor|
          sensor_index = sensor.first
          parsed_response[:data].merge!(sensor_index => {})
          sensor.each_with_index do |data_point, index|
            parsed_response[:data][sensor_index].merge!(fields[index] => data_point)
          end
        end
      end
    end

    class OptionsError < StandardError
    end
  end
end

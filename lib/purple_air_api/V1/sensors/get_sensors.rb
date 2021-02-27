# frozen_string_literal: true

module PurpleAirApi
  module V1
    # Class for requesting sensor from the PurpleAirAPI
    class GetSensors
      attr_accessor :options_hash, :response, :return_hash

      DEFAULT_FIELDS = %w[icon name latitude longitude altitude pm1.0].freeze
      DEFAULT_LOCATION_TYPE = %w[outside inside].freeze

      URL = 'https://api.purpleair.com/v1/sensors'

      def self.call(...)
        new(...).request
      end

      def initialize(client:, **options)
        @http_client = client
        @options_hash = {}
        @return_hash = {}
        create_options_hash(**options)
      end

      def request
        self.response = http_client.get(URL, options_hash)
        parse_response
        return_hash
      end

      private

      attr_reader :http_client, :fields

      def create_options_hash(options)
        options_hash.merge!(
          fields(options[:fields] || DEFAULT_FIELDS),
          location_type(options[:location_type]),
          show_only(options[:show_only]),
          modified_since(options[:modified_since]),
          max_age(options[:max_age])
        )
      end

      def fields(fields)
        { fields: fields.join(',') }
      end

      def show_only(sensor_index)
        sensor_index.nil? ? {} : { show_only: sensor_index.join(',') }
      end

      def location_type(location_type)
        return {} if location_type.nil?

        location_type.map!(&:downcase)
        if location_type.include?('outside') && location_type.include?('inside')
          {}
        elsif location_type.include?('inside') && !location_type.include?('outside')
          { location_type: 1 }
        elsif location_type.include?('outside') && !location_type.include?('inside')
          { location_type: 0 }
        end
      end

      def modified_since(timestamp)
        timestamp.nil? ? {} : { modified_since: timestamp.to_i }
      end

      def max_age(seconds)
        seconds.nil? ? {} : { max_age: seconds.to_i }
      end

      def bounding_box(coordinates)
        if coordinates.nil?
          {}
        else
          {
            nwlng: coordinates[:nwlng].to_i,
            nwlat: coordinates[:nwlat].to_i,
            selng: coordinates[:selng].to_i,
            selat: coordinates[:selat].to_i
          }
        end
      end

      def parse_response
        parsed_response = JSON.parse(response.body)
        fields, data = parsed_response.values_at('fields', 'data')

        data.each do |sensor|
          sensor_index = sensor.first
          return_hash.merge!(sensor_index => {})
          sensor.each_with_index do |data_point, index|
            return_hash[sensor_index].merge!(fields[index] => data_point)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module PurpleAirApi
  module V1
    # Class for requesting sensor from the PurpleAirAPI
    class GetSensors
      attr_accessor :options_hash

      DEFAULT_FIELDS = %w[icon name latitude longitude altitude pm1.0].freeze
      DEFAULT_LOCATION_TYPE = %w[outside inside].freeze

      URL = 'https://api.purpleair.com/v1/sensors'

      def self.call(...)
        new(...).request
      end

      def initialize(client:, **args)
        @http_client = client
        @options_hash = {}
        create_options_hash(**args)
      end

      def request
        http_client.get(URL, options_hash)
      end

      private

      attr_reader :http_client, :fields

      def create_options_hash(options)
        options_hash.merge!(
          fields(options[:fields] || DEFAULT_FIELDS),
          location_type(options[:location_type] || nil),
          show_only(options[:sensor_index])
        )
      end

      def fields(fields)
        { fields: fields.join(',') }
      end

      def show_only(sensor_index)
        sensor_index.nil? ? {} : { sensor_index: sensor_index.join(',') }
      end

      def location_type(location_type)
        if location_type.include?('outside') && location_type.include?('inside')
          location_type = nil
        elsif location_type.include?('inside')
          location_type = 1
        elsif location_type.include?('outside')
          location_type = 0
        end
        location_type.nil? ? {} : { location_type: location_type }
      end
    end
  end
end

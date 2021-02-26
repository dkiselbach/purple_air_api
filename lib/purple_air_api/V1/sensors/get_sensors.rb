# frozen_string_literal: true

module PurpleAirApi
  module V1
    # Class for requesting sensor from the PurpleAirAPI
    class GetSensors
      DEFAULT_FIELDS = {
        "icon": true,
        "name": true,
        "latitude": true,
        "longitude": true,
        "altitude": true,
        "pm1.0": true
      }.freeze

      URL = 'https://api.purpleair.com/v1/sensors'

      def self.call(...)
        new(...).request
      end

      def initialize(client:, options: DEFAULT_FIELDS)
        @http_client = client
        @options = convert_options(options)
      end

      def request
        http_client.get(URL, {
          fields: options
                        })
      end

      private

      attr_reader :http_client, :options

      def convert_options(options)
        options.keys.join(',')
      end
    end
  end
end

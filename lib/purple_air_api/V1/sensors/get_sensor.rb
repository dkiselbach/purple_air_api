# frozen_string_literal: true

module PurpleAirApi
  module V1
    # Class for requesting sensor data for a single sensor. This will return different response formats from the API.
    class GetSensor
      attr_accessor :http_response, :request_options, :index
      attr_reader :http_client

      # The endpoint URL
      URL = 'https://api.purpleair.com/v1/sensors/'

      # Calls initializes the class and requests the data from PurpleAir.
      # @!method call(...)

      def self.call(...)
        new(...).request
      end

      # Creates a HTTP friendly options hash depending on your inputs
      # @!method initialize(client:, sensor_index:, read_key: nil)
      # @param client [Faraday::Connection] Your HTTP client initialized in Client
      # @param sensor_index [Integer] The sensor_index for the sensor you want to request data from.
      # @param read_key [String] The read_key for the sensor you want to request data from if it is a private sensor.

      def initialize(client:, sensor_index:, read_key: nil)
        @http_client = client
        @request_options = {}
        create_options_hash(sensor_index, read_key)
      end

      # Makes a get request to the PurpleAir Get Sensors Data endpoint https://api.purpleair.com/v1/sensors.
      # @!method request
      # @return [PurpleAirApi::V1::GetSensors]

      def request
        self.http_response = http_client.get(url, request_options)
        self
      end

      # Delegate to PurpleAirApi::V1::GetSensor.json_response

      def parsed_response
        json_response
      end

      # Takes the raw response from PurpleAir and parses the JSON into a Hash.
      # @!method json_response
      # @return [Hash]
      # @example json_response example
      #   response.json_response
      #   {
      #     "api_version": "V1.0.6-0.0.9",
      #     "time_stamp": 1615053213,
      #     "sensor": {
      #         "sensor_index": 20,
      #         "name": "Oakdale",
      #         "model": "UNKNOWN",
      #         "location_type": 0,
      #         "latitude": 40.6031,
      #         "longitude": -111.8361,
      #         "altitude": 4636,
      #         "last_seen": 1615053181,
      #         "last_modified": 1575003022,
      #         "private": 0,
      #         "channel_state": 1,
      #         "channel_flags_manual": 2,
      #         "pm1.0_a": 0.0,
      #         "pm2.5_a": 0.0,
      #         "pm10.0_a": 0.0,
      #         "0.3_um_count_a": 0.0,
      #         "0.5_um_count_a": 0.0,
      #         "1.0_um_count_a": 0.0,
      #         "2.5_um_count_a": 0.0,
      #         "5.0_um_count_a": 0.0,
      #         "10.0_um_count_a": 0.0,
      #         "stats_a": {
      #             "pm2.5": 0.0,
      #             "pm2.5_10minute": 0.0,
      #             "pm2.5_30minute": 0.0,
      #             "pm2.5_60minute": 0.0,
      #             "pm2.5_6hour": 0.0,
      #             "pm2.5_24hour": 0.0,
      #             "pm2.5_1week": 0.0,
      #             "time_stamp": 1615053181
      #         },
      #         "analog_input": 0.01,
      #         "primary_id_a": 66984,
      #         "primary_key_a": "TLKXL2SOJ9M0KGFK",
      #         "secondary_id_a": 71207,
      #         "secondary_key_a": "224YRSOGD8TNE5FQ",
      #         "primary_id_b": 209227,
      #         "primary_key_b": "3YF75LZ4DL7HDH9O",
      #         "secondary_id_b": 209228,
      #         "secondary_key_b": "Y02CNZZDMR15KCMX",
      #         "hardware": "1.0+PMSX003-O",
      #         "led_brightness": 0.0,
      #         "firmware_version": "6.01",
      #         "rssi": -78.0,
      #         "icon": 0,
      #         "channel_flags_auto": 0
      #     }
      #   }

      def json_response
        @json_response ||= FastJsonparser.parse(http_response.body)
      end

      private

      def create_options_hash(sensor_index, read_key)
        sensor_index(sensor_index)
        request_options.merge!(
          read_key(read_key)
        )
      end

      def sensor_index(index)
        raise OptionsError, 'sensor_index must be an Integer' unless index.instance_of?(Integer)

        self.index = index.to_s
      end

      def read_key(key)
        return {} if key.nil?

        raise OptionsError, 'read_key must be a String' unless key.instance_of?(String)

        { read_key: key }
      end

      def url
        URL + index
      end
    end
  end
end

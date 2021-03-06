# frozen_string_literal: true

module PurpleAirApi
  # The V1 API Module for namespacing the PurpleAir V1 API
  module V1
    # Client class for interfacing with the V1 PurpleAir API. Refer to the instance methods to learn more about what
    # methods and API options are available.
    class Client
      attr_reader :read_client, :write_client

      # The base URL for the PurpleAir API
      API_URL = 'https://api.purpleair.com/v1/'

      # Creates a read and write client to interface with the Purple Air API.
      # @!method initialize(read_token:, write_token:)
      # @param read_token [String] The read client you received from PurpleAir
      # @param write_token [String] The write client you received from PurpleAir
      # @example generate a client instance
      #   PurpleAirApi::V1::Client.new(read_token: "1234", write_token: "1234")

      def initialize(read_token:, write_token: nil)
        @read_client = create_http_client(read_token)
        @write_client = create_http_client(write_token) unless write_token.nil?
      end

      # Makes a request to the sensors INDEX endpoint and returns an instance of the V1::GetSensors class.
      # @!method request_sensors(options)
      # @param [Hash] options A hash of options { :option_name=>value }
      # @option options [Array<Integer>] :show_only An array of indexes for the sensors you want to request.
      # @option options [Array<String>] :location_type An array of strings specifying sensor location.
      # @option options [Array<String>] :fields An array of fields you want returned.
      # @option options [Integer] :modified_since Only return sensors updated since this timestamp.
      # @option options [Integer] :max_age Only return sensors updated in the last n seconds.
      # @option options [Hash<array>] :bounding_box A hash with a :nw and :se array { nw: [lat,long], se: [lat,long] }.
      # @example
      #   { bounding_box: { nw: [37.7790262, -122.4199061], se: [37.6535403, -122.4168664]}}
      # @option options [Array<String>] :read_keys An array of read-keys which are required for private devices.
      # @return [PurpleAirApi::GetSensors]
      # @example request sensor data for a few sensors
      #   options = { fields: ['icon', 'name'], location_type: ['outside'], show_only: [20, 47], max_age: 3600}
      #   client = PurpleAirApi::V1::Client.new(read_token: "1234", write_token: "1234")
      #   response = client.request_sensors(options)
      #   response_hash = response.parsed_response

      def request_sensors(options = {})
        GetSensors.call(client: read_client, **options)
      end

      # Makes a request to the individual sensor SHOW endpoint and returns an instance of the V1::GetSensors class.
      # @!method request_sensor(sensor_index, read_key: nil)
      # @param sensor_index [Integer] The sensor_index for the sensor you want to request data from.
      # @param read_key [String] The read_key for the sensor you want to request data from if it is a private sensor.
      # @return [PurpleAirApi::GetSensor]
      # @example request sensor data for a few sensors
      #   client = PurpleAirApi::V1::Client.new(read_token: "1234")
      #   response = client.request_sensor(sensor_index: 20)
      #   response_hash = response.parsed_response

      def request_sensor(sensor_index:, read_key: nil)
        GetSensor.call(client: read_client, sensor_index: sensor_index, read_key: read_key)
      end

      private

      def create_http_client(token)
        Faraday.new(url: API_URL) do |faraday|
          faraday.headers['X-API-KEY'] = token
          faraday.use RaiseHttpException
        end
      end
    end
  end
end

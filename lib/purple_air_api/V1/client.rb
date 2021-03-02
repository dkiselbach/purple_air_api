# frozen_string_literal: true

module PurpleAirApi
  module V1
    # Client class for interfacing with the V1 PurpleAir API. Refer to the instance methods to learn more about what
    # methods and API options are available.
    class Client
      API_URL = 'https://api.purpleair.com/v1/'

      attr_reader :read_client, :write_client

      # Creates a read and write client to interface with the Purple Air API.
      # @!method initialize(read_token:, write_token:)
      # @param read_token [String] The read client you received from PurpleAir
      # @param write_token [String] The write client you received from PurpleAir

      def initialize(read_token:, write_token:)
        @read_client = create_http_client(read_token)
        @write_client = create_http_client(write_token)
      end

      # Makes a request to the sensors endpoint and returns a parsed JSON.
      # @!method request_sensors(options)
      # @param [Hash] options A hash of options { :option_name=>value }
      # @option options [Array<Integer>] :show_only An array of indexes for the sensors you want to request.
      # @option options [Array<String>] :location_Type An array of strings specifying sensor location.
      # @option options [Array<String>] :fields An array of fields you want returned.
      # @option options [Array<String>] :modified_since An array of fields you want returned.
      # @option options [Array<String>] :max_age An array of fields you want returned.
      # @option options [Array<String>] :bounding_box An array of fields you want returned.
      # @option options [Array<String>] :read_keys An array of fields you want returned.
      # @return [JSON]

      def request_sensors(options)
        GetSensors.call(client: read_client, **options)
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

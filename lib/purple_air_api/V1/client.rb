# frozen_string_literal: true

require 'faraday'

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
      # @!method request_sensor_data
      #

      def request_sensor_data
        GetSensors.call(client: read_client)
      end

      private

      def create_http_client(token)
        Faraday.new(url: API_URL) do |faraday|
          faraday.headers['X-API-KEY'] = token
        end
      end
    end
  end
end

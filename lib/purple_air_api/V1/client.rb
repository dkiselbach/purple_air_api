# frozen_string_literal: true

require 'faraday'

module PurpleAirApi
  module V1
    # Client class for interfacing with the V1 PurpleAir API
    class Client
      API_URL = 'https://api.purpleair.com/v1/'

      attr_reader :read_client, :write_client

      def initialize(read_token:, write_token:)
        @read_client = create_http_client(read_token)
        @write_client = create_http_client(write_token)
      end

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

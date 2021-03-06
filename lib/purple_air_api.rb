# frozen_string_literal: true

require 'faraday'
require 'fast_jsonparser'
require_relative 'purple_air_api/version'
require_relative 'purple_air_api/V1/client'
require_relative 'purple_air_api/V1/raise_http_exception'
require_relative 'purple_air_api/V1/errors'
require_relative 'purple_air_api/v1/sensors/get_sensors'
require_relative 'purple_air_api/v1/sensors/get_sensor'
require_relative 'purple_air_api/v1/sensors/errors'

# The PurpleAirApi is a gem intended to be used to interact with the PurpleAir API easily.
module PurpleAirApi
  # Alias for PurpleAirApi::V1::Client.new
  #
  # @return [PurpleAirApi::V1::Client]
  # @example requesting data for a few sensors
  #   options = { fields: ['icon', 'name'], location_type: ['outside'], show_only: [26, 41], max_age: 3600}
  #   PurpleAirApi.client(read_token: "1234", write_token: "1234").request_sensors(options)

  def self.client(read_token:, write_token: nil)
    PurpleAirApi::V1::Client.new(read_token: read_token, write_token: write_token)
  end

  # Delegate to PurpleAirApi::V1::Client
  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)

    client.send(method, *args, &block)
  end

  # Delegate to PurpleAirApi::V1::Client
  def self.respond_to?(method, include_all: false)
    client.respond_to?(method, include_all) || super
  end

  # Delegate to PurpleAirApi::V1::Client
  def self.respond_to_missing?(method_name, include_private: false)
    client.respond_to_missing?(method_name, include_private) || super
  end
end

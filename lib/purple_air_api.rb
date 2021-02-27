# frozen_string_literal: true

require 'faraday'
require 'fast_jsonparser'
require_relative 'purple_air_api/version'
require_relative 'purple_air_api/V1/client'
require_relative 'purple_air_api/v1/sensors/get_sensors'

module PurpleAirApi
  class Error < StandardError; end
  # Your code goes here...
end

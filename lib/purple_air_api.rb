# frozen_string_literal: true

require 'faraday'
require 'fast_jsonparser'
require_relative 'purple_air_api/version'
require_relative 'purple_air_api/V1/client'
require_relative 'purple_air_api/V1/raise_http_exception'
require_relative 'purple_air_api/V1/errors'
require_relative 'purple_air_api/v1/sensors/get_sensors'

module PurpleAirApi
end

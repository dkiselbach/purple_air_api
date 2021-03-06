# frozen_string_literal: true

module PurpleAirApi
  module V1
    # A custom error class for rescuing from all PurpleAir API errors
    class BaseError < StandardError
      attr_reader :response_object, :error_type

      # Initialize the error object with error_type and the Faraday response object. PurpleAir returns a human friendly
      # error message and type which is added here. You can also reference the response to view the raw response
      # from PurpleAir.
      # @!method initialize(message, error_type, response_object)
      # @param message [String] the message you want displayed when the error is raised
      # @param error_type [String] the error type that PurpleAir includes in the JSON response
      # @param response_object [Faraday::Env] the Faraday response object
      def initialize(message, error_type, response_object)
        super(message)
        @error_type = error_type
        @response_object = response_object
      end
    end

    # Raised when the PurpleAir API returns the HTTP status code 403
    class ApiKeyError < BaseError
    end

    # Raised when the PurpleAir API returns the HTTP status code 415
    class MissingJsonPayloadError < BaseError
    end

    # Raised when the PurpleAir API returns the HTTP status code 400. Use the message and error_type on the Error
    # object to determine additional information regarding the error.
    class ApiError < BaseError
    end

    # Raised when the PurpleAir API returns the HTTP status code 404
    class NotFoundError < BaseError
    end

    # Raised when the PurpleAir API returns the HTTP status code 500
    class ServerError < BaseError
    end
  end
end

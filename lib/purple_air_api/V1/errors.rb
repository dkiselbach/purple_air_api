# frozen_string_literal: true

module PurpleAirApi
  module V1
    # A custom error class for rescuing from all PurpleAir API errors
    class BaseError < StandardError
      attr_reader :response_object, :error_type

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
    class InternalServerError < BaseError
    end
  end
end

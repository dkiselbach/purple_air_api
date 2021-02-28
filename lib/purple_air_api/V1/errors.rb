# frozen_string_literal: true

module PurpleAirApi
  module V1
    # The base error which all custom errors will inherit from
    class BaseError < StandardError
      attr_reader :object

      def initialize(message, object = nil)
        super(message)
        @object = object
      end
    end

    class ApiKeyInvalidError < BaseError
    end

    class InvalidFieldError < BaseError
    end

    class UnknownApiError < BaseError
    end

    class InternalServerError < BaseError
    end

    class OptionsError < BaseError
    end
  end
end

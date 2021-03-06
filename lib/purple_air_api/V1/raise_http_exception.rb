# frozen_string_literal: true

module PurpleAirApi
  module V1
    # Handles any HTTP exceptions for 400 and 500 error codes
    class RaiseHttpException < Faraday::Middleware
      # A switch statement which determines which error to raise depending on error code
      def call(env)
        @app.call(env).on_complete do |response|
          self.response = response
          case response[:status].to_i
          when 400
            raise ApiError.new(error_message, parsed_response[:error], response)
          when 403
            raise ApiKeyError.new(error_message, parsed_response[:error], response)
          when 404
            raise NotFoundError.new(error_message, parsed_response[:error], response)
          when 415
            raise MissingJsonPayloadError.new(error_message, 'MissingJsonPayloadError', response)
          when 500
            raise ServerError.new(error_message, 'ServerError', response)
          end
        end
      end

      # Faraday syntax for implementing middleware
      def initialize(app)
        super app
        @parser = nil
      end

      private

      attr_accessor :response

      def error_message
        parsed_response[:description]
      end

      def parsed_response
        @parsed_response ||= FastJsonparser.parse(response[:body])
      rescue FastJsonparser::ParseError
        unknown_error_message
      end

      def unknown_error_message
        { description: 'Something went wrong in the request.' }
      end
    end
  end
end

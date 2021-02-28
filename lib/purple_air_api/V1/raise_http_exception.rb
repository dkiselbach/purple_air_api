# frozen_string_literal: true

module PurpleAirApi
  module V1
    # @private
    class RaiseHttpException < Faraday::Middleware
      def call(env)
        @app.call(env).on_complete do |response|
          case response[:status].to_i
          when 400
            error_handler400(response)
          when 403
            raise ApiKeyInvalidError.new(error_message400(response), response)
          when 500
            raise InternalServerError.new(
              error_message500(response, 'The server returned an invalid or incomplete response.'), response
            )
          end
        end
      end

      def initialize(app)
        super app
        @parser = nil
      end

      private

      def error_handler400(response)
        error = parsed_response(response)[:error] || 'UnknownError'

        raise InvalidFieldError.new(error_message400(response), response) if error == 'InvalidFieldValueError'

        raise UnknownApiError.new(error_message400(response), response)
      end

      def error_message400(response)
        error_description = parsed_response(response)[:description]
        "#{response[:method].to_s.upcase} #{response[:url]}: #{response[:status]} #{error_description}"
      end

      def error_message500(response, body = nil)
        "#{response[:method].to_s.upcase} #{response[:url]}: #{["#{response[:status]}:",
                                                                body].compact.join(' ')}"
      end

      def parsed_response(response)
        @parsed_response ||= FastJsonparser.parse(response[:body])
      end
    end
  end
end

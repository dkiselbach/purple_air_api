# frozen_string_literal: true

require_relative '../../spec/support/shared_contexts/v_1'

RSpec.describe PurpleAirApi::V1::RaiseHttpException do
  include_context 'with valid client'

  describe '#call' do
    subject(:request) { client.request_sensors({}) }

    before do
      WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors')
             .with(headers: { 'X-API-KEY': read_token },
                   query: { fields: 'icon,name,latitude,longitude,altitude,pm2.5' })
             .to_return(
               body: WebmockHelper.response_body(path),
               status: status_code,
               headers: { 'content-type' => 'application/json' }
             )
    end

    describe PurpleAirApi::V1::ApiKeyError do
      let(:status_code) { 403 }

      context 'when key is invalid' do
        let(:path) { 'V1/errors/api_key_invalid_error.json' }

        it 'raises ApiKeyError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'The provided api_key was not valid.'
            expect(error.error_type).to eq 'ApiKeyInvalidError'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end

      context 'when key is missing' do
        let(:path) { 'V1/errors/api_key_missing_error.json' }

        it 'raises ApiKeyMissingError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'No API key was found in the request.'
            expect(error.error_type).to eq 'ApiKeyMissingError'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end

      context 'when key is restricted' do
        let(:path) { 'V1/errors/api_key_restricted_error.json' }

        it 'raises ApiKeyRestrictedError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'The provided API key is restricted to certain hosts or referrers.'
            expect(error.error_type).to eq 'ApiKeyRestrictedError'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end

      context 'when key is the wrong type' do
        let(:path) { 'V1/errors/api_key_type_mismatch_error.json' }

        it 'raises ApiKeyTypeMismatchError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'The provided key was of the wrong type (READ or WRITE).'
            expect(error.error_type).to eq 'ApiKeyTypeMismatchError'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end

      context 'when api servlet error is returned' do
        let(:path) { 'V1/errors/api_servlet_error.json' }

        it 'raises ApiServletError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'A server error occurred. See the message for more details.'
            expect(error.error_type).to eq 'ApiServletException'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end
    end

    describe PurpleAirApi::V1::ApiError do
      let(:status_code) { 400 }

      context 'when api sql error is returned' do
        let(:path) { 'V1/errors/api_sql_exception.json' }

        it 'raises ApiSqlExecption' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'A server error occurred. See the message for more details.'
            expect(error.error_type).to eq 'ApiSqlException'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end

      context 'when data initializing error is returned' do
        let(:path) { 'V1/errors/data_initializing_error.json' }

        it 'raises DataInitializingError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'The server is busy loading data and you should try again in 10 seconds.'
            expect(error.error_type).to eq 'DataInitializingError'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end

      context 'when invalid request url error is returned' do
        let(:path) { 'V1/errors/invalid_request_url_error.json' }

        it 'raises InvalidRequestUrlError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'The url used in the request was invalid. Please check it and try again.'
            expect(error.error_type).to eq 'InvalidRequestUrlError'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end

      context 'when not requires http error is returned' do
        let(:path) { 'V1/errors/requires_http_error.json' }

        it 'raises RequiresHttpsError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'HTTPS is required to access this service.'
            expect(error.error_type).to eq 'RequiresHttpsError'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end

      context 'when not unknown error is returned' do
        let(:path) { 'V1/errors/unknown_error.json' }

        it 'raises ApiUnknownError' do
          expect { request }.to raise_error(described_class) do |error|
            expect(error.message).to eq 'SA server error occurred. See the message for more details.'
            expect(error.error_type).to eq 'ApiUnknownError'
            expect(error.response_object).to be_instance_of(Faraday::Env)
          end
        end
      end
    end

    describe PurpleAirApi::V1::MissingJsonPayloadError do
      let(:status_code) { 415 }
      let(:path) { 'V1/errors/missing_json_payload_error.json' }

      it 'raises MissingJsonPayloadError' do
        expect { request }.to raise_error(described_class) do |error|
          expect(error.message).to eq 'Content-Type: application/json header present but no JSON payload was found.'
          expect(error.error_type).to eq 'MissingJsonPayloadError'
          expect(error.response_object).to be_instance_of(Faraday::Env)
        end
      end
    end

    describe PurpleAirApi::V1::NotFoundError do
      let(:status_code) { 404 }
      let(:path) { 'V1/errors/not_found_error.json' }

      it 'raises NotFoundError' do
        expect { request }.to raise_error(described_class) do |error|
          expect(error.message).to eq 'Cannot find a sensor with the provided parameters.'
          expect(error.error_type).to eq 'NotFoundError'
          expect(error.response_object).to be_instance_of(Faraday::Env)
        end
      end
    end

    describe PurpleAirApi::V1::ServerError do
      let(:status_code) { 500 }
      let(:path) { 'V1/errors/server_error.json' }

      it 'raises InternalServerError' do
        expect { request }.to raise_error(described_class) do |error|
          expect(error.message).to eq 'Something went wrong in the request.'
          expect(error.error_type).to eq 'ServerError'
          expect(error.response_object).to be_instance_of(Faraday::Env)
        end
      end
    end
  end
end

# frozen_string_literal: true

require_relative '../../../spec/support/shared_contexts/v_1'

RSpec.describe PurpleAirApi::V1::GetSensor do
  let(:sensor_index) { 20 }
  let(:read_key) { nil }

  include_context 'with valid client'

  describe '#initialize' do
    subject(:get_sensor) do
      described_class.new(client: client.read_client, sensor_index: sensor_index, read_key: read_key)
    end

    context 'when only index options are given' do
      it { expect(get_sensor.http_client.class).to eq(Faraday::Connection) }
      it { expect(get_sensor.index).to eq(20.to_s) }
    end

    context 'when all options are given' do
      let(:read_key) { 'key-one' }

      it 'options_hash is set correctly' do
        correct_hash = {
          read_key: 'key-one'
        }

        expect(subject.request_options).to eq(correct_hash)
      end
    end

    context 'when sensor_index is invalid' do
      let(:sensor_index) { '20' }
      it 'returns OptionsError' do
        expect { subject }.to raise_error(PurpleAirApi::V1::OptionsError)
      end
    end

    context 'when read_key is invalid' do
      let(:read_key) { 1234 }
      it 'returns OptionsError' do
        expect { subject }.to raise_error(PurpleAirApi::V1::OptionsError)
      end
    end
  end

  describe '#request' do
    subject(:get_sensor_request) do
      described_class.call(client: client.read_client, sensor_index: sensor_index, read_key: read_key)
    end

    context 'when read_token and options are valid' do
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors/20')
               .with(headers: { 'X-API-KEY': read_token })
               .to_return(
                 body: WebmockHelper.response_body('V1/get_sensor/response.json'),
                 status: 200,
                 headers: { 'content-type' => 'application/json' }
               )
      end

      it 'returns 200 response' do
        expect(get_sensor_request.http_response.status).to eql(200)
      end

      it 'returns http response' do
        expect(get_sensor_request.http_response.class).to eql(Faraday::Response)
      end

      it 'hash has data labelled by sensor index' do
        response = WebmockHelper.response_body('V1/get_sensor/response.json')
        expect(get_sensor_request.parsed_response).to eql(FastJsonparser.parse(response))
      end

      it 'returns correct number of data points' do
        expect(get_sensor_request.parsed_response[:sensor].count).to eql(37)
      end
    end

    context 'when read token is invalid' do
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors/20')
               .with(headers: { 'X-API-KEY': read_token })
               .to_return(
                 body: WebmockHelper.response_body('V1/errors/api_key_invalid_error.json'),
                 status: 403,
                 headers: { 'content-type' => 'application/json' }
               )
      end

      it 'raises ApiError' do
        expect { get_sensor_request }.to raise_error(PurpleAirApi::V1::ApiKeyError)
      end
    end

    context 'when read key is invalid' do
      let(:read_key) { 'invalid' }
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors/20')
               .with(headers: { 'X-API-KEY': read_token },
                     query: {
                       read_key: 'invalid'
                     })
               .to_return(
                 body: WebmockHelper.response_body('V1/get_sensor/invalid_data_read_key_error.json'),
                 status: 400,
                 headers: { 'content-type' => 'application/json' }
               )
      end

      it 'raises ApiError with error type' do
        expect { get_sensor_request }.to raise_error(PurpleAirApi::V1::ApiError) do |error|
          expect(error.error_type).to eq('InvalidDataReadKeyError')
        end
      end
    end
  end
end

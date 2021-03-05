# frozen_string_literal: true

require_relative '../../../spec/support/shared_contexts/v_1'

RSpec.describe PurpleAirApi::V1::GetSensors do
  let(:options) { { fields: %w[icon name latitude longitude altitude pm1.0] } }

  include_context 'with valid client'

  describe '#initialize' do
    subject(:get_sensors) { described_class.new(client: client.read_client, **options) }
    context 'when only field options are given' do
      it { expect(get_sensors.http_client.class).to eq(Faraday::Connection) }
      it { expect(get_sensors.request_options).to eq({ fields: 'icon,name,latitude,longitude,altitude,pm1.0' }) }
    end

    context 'when all options are given' do
      let(:options) do
        {
          fields: %w[icon name latitude longitude altitude pm1.0],
          location_type: %w[inside],
          show_only: [50, 70, 90],
          modified_since: 1_614_480_946,
          max_age: 3600,
          bounding_box: { nw: [49, 33], se: [22, 27] },
          read_keys: %w[key-one key-two]
        }
      end

      it 'options_hash is set correctly' do
        correct_hash = {
          fields: 'icon,name,latitude,longitude,altitude,pm1.0', max_age: 3600,
          modified_since: 1_614_480_946, nwlat: 49,
          nwlng: 33, read_keys: 'key-one,key-two',
          selat: 22, selng: 27,
          show_only: '50,70,90', location_type: 1
        }

        expect(get_sensors.request_options).to eq(correct_hash)
      end
    end

    context 'when options are invalid' do
      option_keys = %w[fields show_only location_type modified_since max_age bounding_box read_keys].map(&:to_sym)
      options = %w[icon 1234 outside 54321 3600 1,2,3,4 key-one]

      option_keys.each_with_index do |field, index|
        it "returns OptionsError with error message for #{field}" do
          options_hash = { field => options[index] }
          expect do
            described_class.new(client: client.read_client, **options_hash)
          end.to raise_error(PurpleAirApi::V1::OptionsError)
        end
      end
    end
  end

  describe '#request' do
    subject(:get_sensors_request) { described_class.call(client: client.read_client, **options) }

    context 'when read_token and options are valid' do
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors')
               .with(headers: { 'X-API-KEY': read_token },
                     query: { fields: 'icon,name,latitude,longitude,altitude,pm1.0' })
               .to_return(
                 body: WebmockHelper.response_body('V1/get_sensors/response.json'),
                 status: 200,
                 headers: { 'content-type' => 'application/json' }
               )
      end

      it 'returns 200 response' do
        expect(get_sensors_request.http_response.status).to eql(200)
      end

      it 'returns http response' do
        expect(get_sensors_request.http_response.class).to eql(Faraday::Response)
      end

      it 'hash has data labelled by sensor index' do
        expect(get_sensors_request.parsed_response[:data][20]).to eql({
                                                                        'altitude' => 4636, 'icon' => 0, 'latitude' => 40.6031,
                                                                        'longitude' => -111.8361, 'name' => 'Oakdale',
                                                                        'pm1.0' => 0.0, 'sensor_index' => 20
                                                                      })
      end

      it 'returns correct number of data points' do
        expect(get_sensors_request.parsed_response[:data].count).to eql(10)
      end
    end

    context 'when read token is invalid' do
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors')
               .with(headers: { 'X-API-KEY': read_token },
                     query: { fields: 'icon,name,latitude,longitude,altitude,pm1.0' })
               .to_return(
                 body: WebmockHelper.response_body('V1/errors/api_key_invalid_error.json'),
                 status: 403,
                 headers: { 'content-type' => 'application/json' }
               )
      end

      it 'raises ApiError' do
        expect { get_sensors_request }.to raise_error(PurpleAirApi::V1::ApiKeyError)
      end
    end

    context 'when field is invalid' do
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors')
               .with(headers: { 'X-API-KEY': read_token },
                     query: { fields: 'icon,name,latitude,longitude,altitude,pm1.0' })
               .to_return(
                 body: WebmockHelper.response_body('V1/get_sensors/invalid_field_error.json'),
                 status: 400,
                 headers: { 'content-type' => 'application/json' }
               )
      end

      it 'raises ApiError with error type' do
        expect { get_sensors_request }.to raise_error(PurpleAirApi::V1::ApiError) do |error|
          expect(error.error_type).to eq('InvalidFieldValueError')
        end
      end
    end

    context 'when error is unknown' do
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors')
               .with(headers: { 'X-API-KEY': read_token },
                     query: { fields: 'icon,name,latitude,longitude,altitude,pm1.0' })
               .to_return(
                 body: WebmockHelper.response_body('V1/errors/unknown_error.json'),
                 status: 400,
                 headers: { 'content-type' => 'application/json' }
               )
      end

      it { expect { get_sensors_request }.to raise_error(PurpleAirApi::V1::ApiError) }
    end

    context 'when error is unknown' do
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors')
               .with(headers: { 'X-API-KEY': read_token },
                     query: { fields: 'icon,name,latitude,longitude,altitude,pm1.0' })
               .to_return(
                 status: 500
               )
      end

      it { expect { get_sensors_request }.to raise_error(PurpleAirApi::V1::InternalServerError) }
    end
  end
end

# frozen_string_literal: true

require_relative '../../../spec/support/shared_contexts/v_1'

RSpec.describe PurpleAirApi::V1::GetSensors do
  subject(:get_sensors) { described_class.call(client: client.read_client) }

  include_context 'with valid client'

  describe '#request' do
    context 'when read_token is valid' do
      before do
        WebMock.stub_request(:get, 'https://api.purpleair.com/v1/sensors')
               .with(headers: { 'X-API-KEY': read_token },
                     query: { fields: 'icon,name,latitude,longitude,altitude,pm1.0' })
               .to_return(
                 body: WebmockHelper.response_body('V1/get_sensors.json'),
                 status: 200,
                 headers: { 'content-type' => 'application/json' }
               )
      end

      it 'returns 200 response' do
        expect(get_sensors.status).to eql(200)
      end

      it 'returns JSON body' do
        expect(JSON.parse(get_sensors.body).count).to eql(6)
      end
    end
  end
end

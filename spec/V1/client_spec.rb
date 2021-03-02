# frozen_string_literal: true

RSpec.describe PurpleAirApi::V1::Client do
  subject(:client) { described_class.new(read_token: read_token, write_token: write_token) }

  let(:read_token) { Faker::Internet.uuid }
  let(:write_token) { Faker::Internet.uuid }

  describe '#initialize' do
    context 'when valid inputs are given' do
      it { expect(client).to be_instance_of(described_class) }
      it { expect(subject.read_client.headers).to include({ 'X-API-KEY' => read_token }) }
      it { expect(subject.read_client).to be_instance_of(Faraday::Connection) }
      it { expect(subject.write_client.headers).to include({ 'X-API-KEY' => write_token }) }
      it { expect(subject.write_client).to be_instance_of(Faraday::Connection) }
      it { expect(subject.read_client.url_prefix.to_s).to eq('https://api.purpleair.com/v1/') }
      it { expect(subject.write_client.url_prefix.to_s).to eq('https://api.purpleair.com/v1/') }
    end
  end

  describe '#request_sensor_data' do
    context 'when valid options given' do
      it 'makes a request to the get_sensors class' do
        allow(PurpleAirApi::V1::GetSensors).to receive(:call).and_return({})

        subject.request_sensors({})
        expect(PurpleAirApi::V1::GetSensors).to have_received(:call)
      end
    end
  end
end

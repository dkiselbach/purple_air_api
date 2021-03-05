# frozen_string_literal: true

RSpec.shared_context 'with valid client' do
  let(:read_token) { Faker::Internet.uuid }
  let(:write_token) { Faker::Internet.uuid }
  let(:client) { PurpleAirApi.client(read_token: read_token, write_token: write_token) }
end

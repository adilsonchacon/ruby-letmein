# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApiError do
  describe '.initalize' do
    context 'when has invalid credentials even with a valid token' do
      subject(:client) { RubyLetmein.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'fails' do
        VCR.use_cassette('sign_in_failure_for_api_error') do
          client.sign_in('invalid.user@example.com', 'Secret.123#!')
          expect(client.api_error).not_to be_nil
          expect(client.api_error.code).to eq '401'
          expect(client.api_error.parsed_response_body).to include({"message"=>"invalid credentials"})
        end
      end
    end
  end
end

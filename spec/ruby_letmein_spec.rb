# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLetmein do
  describe '.initialize' do
    context 'when has a valid url' do
      subject(:client) { described_class.new('http://localhost:3000', 'any token') }

      it { expect(client.base_url).to eq('http://localhost:3000') }
      it { expect(client.app_token).to eq('any token') }
    end

    context 'when has an invalid url' do
      subject(:client) { described_class.new('invalid url', 'any token') }

      it { expect { client }.to raise_error(URI::InvalidURIError) }
    end
  end

  describe '.sign_in' do
    context 'when has valid credentials and token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'is successful' do
        VCR.use_cassette('sign_in_success') do
          expect(client.sign_in('valid.user@example.com', 'Secret.123!#')).to be_truthy
        end
      end
    end

    context 'when has invalid credentials even with a valid token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'fails' do
        VCR.use_cassette('sign_in_failure') do
          expect(client.sign_in('invalid.user@example.com', 'Secret.123#!')).to be_falsey
        end
      end
    end

    context 'when has valid credentials but an invalid token' do
      subject(:client) { described_class.new('http://localhost:3000', 'invalid token') }

      it 'fails' do
        VCR.use_cassette('sign_in_failure') do
          expect(client.sign_in('valid.user@example.com', 'Secret.123#!')).to be_falsey
        end
      end
    end
  end

  describe '.sign_out' do
    context 'when has valid api token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'is successful' do
        VCR.use_cassette('sign_in_success_for_sign_out_success') do
          client.sign_in('valid.user@example.com', 'Secret.123!#')
        end

        VCR.use_cassette('sign_out_success') do
          expect(client.sign_out).to be_truthy
        end
      end
    end

    context 'when has an invalid token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'fails' do
        VCR.use_cassette('sign_in_success_for_sign_out_failure') do
          client.sign_in('valid.user@example.com', 'Secret.123!#')
        end

        client.auth_token = 'invalid token'

        VCR.use_cassette('sign_out_failure') do
          expect(client.sign_out).to be_falsey
        end
      end
    end

    context 'when is not signed_in' do
      subject(:client) { described_class.new('http://localhost:3000', 'invalid token') }

      it 'fails' do
        VCR.use_cassette('sign_out_failure') do
          expect(client.sign_out).to be_falsey
        end
      end
    end
  end

  describe '.signed_in?' do
    context 'when has valid api token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'is successful' do
        VCR.use_cassette('sign_in_success_for_signed_in_success') do
          client.sign_in('valid.user@example.com', 'Secret.123!#')
        end

        VCR.use_cassette('signed_in_success') do
          expect(client.signed_in?).to be_truthy
        end
      end
    end

    context 'when has an invalid token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'fails' do
        VCR.use_cassette('sign_in_success_for_signed_in_failure') do
          client.sign_in('valid.user@example.com', 'Secret.123!#')
        end

        client.auth_token = 'invalid token'

        VCR.use_cassette('signed_in_failure') do
          expect(client.signed_in?).to be_falsey
        end
      end
    end

    context 'when is not signed_in' do
      subject(:client) { described_class.new('http://localhost:3000', 'invalid token') }

      it 'fails' do
        VCR.use_cassette('signed_in_failure') do
          expect(client.signed_in?).to be_falsey
        end
      end
    end
  end

  describe '.current_user' do
    context 'when has valid api token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'is successful' do
        VCR.use_cassette('sign_in_success_for_current_user_success') do
          client.sign_in('valid.user@example.com', 'Secret.123!#')
        end

        VCR.use_cassette('current_user_success') do
          current_user = client.current_user
          expect(current_user).to include({ 'email' => 'valid.user@example.com' })
          expect(current_user).to include({ 'name' => 'valid.user' })
        end
      end
    end

    context 'when has an invalid token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'fails' do
        VCR.use_cassette('sign_in_success_for_current_user_failure') do
          client.sign_in('valid.user@example.com', 'Secret.123!#')
        end

        client.auth_token = 'invalid token'

        VCR.use_cassette('current_user_failure') do
          expect(client.current_user).to be_nil
        end
      end
    end

    context 'when is not signed_in' do
      subject(:client) { described_class.new('http://localhost:3000', 'invalid token') }

      it 'fails' do
        VCR.use_cassette('current_user_failure') do
          expect(client.current_user).to be_nil
        end
      end
    end
  end

  describe '.refresh_current_user' do
    context 'when has valid api token' do
      subject(:client) { described_class.new('http://localhost:3000', '1AyGDHZzuobEfD1HvJjeQtuKioorzShu') }

      it 'is successful' do
        VCR.use_cassette('sign_in_success_for_refresh_current_user') do
          client.sign_in('valid.user@example.com', 'Secret.123!#')
        end

        current_user = {}
        VCR.use_cassette('current_user_for_refresh_current_user') do
          current_user = client.current_user
          current_user['name'] = 'New Name'
        end

        VCR.use_cassette('refresh_current_user_success') do
          refreshed_current_user = client.refresh_current_user
          expect(current_user['id']).to eq(refreshed_current_user['id'])
          expect(current_user['name']).not_to eq(refreshed_current_user['name'])
        end
      end
    end
  end
end

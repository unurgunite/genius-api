# frozen_string_literal: true

require 'genius/api'

describe Genius::Auth do
  describe '.authorized?' do
    context 'with valid token' do
      let(:valid_token) { 'a' * 64 }

      before do
        described_class.logout!
        allow(Genius::Errors).to receive(:validate_token)
        described_class.login = valid_token
      end

      it 'returns true' do
        expect(described_class.authorized?).to be true
      end
    end

    context 'with invalid token' do
      before do
        described_class.logout!
        allow(Genius::Errors).to receive(:validate_token).and_raise(Genius::Errors::TokenError.new)
      end

      it 'returns false' do
        described_class.login = 'invalid_token'
        expect(described_class.authorized?).to be false
      end
    end
  end

  describe '.logout!' do
    it 'sets the token to nil' do
      described_class.logout!
      expect(described_class.instance_variable_get(:@token)).to be_nil
    end
  end
end

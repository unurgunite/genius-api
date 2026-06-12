# frozen_string_literal: true

require 'extensions/extensions'

describe Object do
  describe '#token_ext' do
    subject(:helper) { described_class.new }

    let(:token) { 'a' * 64 }

    context 'when a token is provided' do
      it 'returns the token' do
        expect(helper.token_ext(token)).to eq(token)
      end
    end

    context 'when token is nil and Genius::Auth has an instance variable @token' do
      before do
        Genius::Auth.instance_variable_set(:@token, token)
      end

      after do
        Genius::Auth.instance_variable_set(:@token, nil)
      end

      it 'returns the stored token' do
        expect(helper.token_ext(nil)).to eq(token)
      end
    end
  end
end

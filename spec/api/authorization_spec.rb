# frozen_string_literal: true

require 'rspec'
require 'genius/api'

describe Genius::Auth, ' .authorized? with valid token' do
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

describe Genius::Auth, ' .authorized? with invalid token' do
  before do
    described_class.logout!
    allow(Genius::Errors).to receive(:validate_token).and_raise(Genius::Errors::TokenError.new)
  end

  it 'returns false' do
    described_class.login = 'invalid_token'
    expect(described_class.authorized?).to be false
  end
end

describe Genius::Auth, ' .logout!' do
  it 'sets the token to nil' do
    described_class.logout!
    expect(described_class.instance_variable_get(:@token)).to be_nil
  end
end

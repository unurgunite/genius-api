# frozen_string_literal: true

require 'rspec'
require 'genius/api'

describe Genius::Account, ' .account with valid token' do
  let(:token) { 'a' * 64 }
  let(:response_body) { { 'meta' => { 'status' => 200 }, 'response' => { 'user' => { 'name' => 'Test' } } }.to_json }
  let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

  before do
    allow(HTTParty).to receive(:get).and_return(mock_response)
  end

  it 'returns account info as a hash' do
    result = described_class.account(token: token)
    expect(result).to be_a(Hash)
    expect(result.dig('meta', 'status')).to eq(200)
  end

  it 'sends a GET request to the account endpoint' do
    described_class.account(token: token)
    expect(HTTParty).to have_received(:get).with(
      "https://api.genius.com/account?access_token=#{token}"
    )
  end
end

describe Genius::Account, ' .account without token' do
  before do
    allow(Genius::Auth).to receive(:authorized?).and_return(false)
  end

  it 'returns nil' do
    expect(described_class.account(token: nil)).to be_nil
  end
end

describe Genius::Account, ' .me' do
  let(:token) { 'a' * 64 }
  let(:response_body) { { 'meta' => { 'status' => 200 }, 'response' => { 'user' => { 'name' => 'Test' } } }.to_json }
  let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

  before do
    allow(HTTParty).to receive(:get).and_return(mock_response)
  end

  it 'behaves the same as .account' do
    expect(described_class.me(token: token)).to eq(described_class.account(token: token))
  end
end

# frozen_string_literal: true

require 'rspec'
require 'genius/api'

describe Genius::WebPages, ' .lookup with valid token' do
  let(:token) { 'a' * 64 }
  let(:response_body) do
    {
      'meta' => { 'status' => 200 },
      'response' => { 'web_page' => { 'id' => 1, 'url' => 'https://example.com' } }
    }.to_json
  end

  before do
    allow(Genius::Errors).to receive(:validate_token)
    allow(HTTParty).to receive(:get).and_return(response_body)
  end

  it 'returns web page data as a hash' do
    result = described_class.lookup(token: token)
    expect(result).to be_a(Hash)
    expect(result.dig('meta', 'status')).to eq(200)
  end

  it 'sends a GET request to the API root' do
    described_class.lookup(token: token)
    expect(HTTParty).to have_received(:get).with(
      "https://api.genius.com/?access_token=#{token}"
    )
  end
end

describe Genius::WebPages, ' .lookup with URL variants' do
  let(:token) { 'a' * 64 }
  let(:response_body) { { 'meta' => { 'status' => 200 }, 'response' => { 'web_page' => { 'id' => 1, 'url' => 'https://example.com' } } }.to_json }
  before do
    allow(Genius::Errors).to receive(:validate_token)
    allow(HTTParty).to receive(:get).and_return(response_body)
  end
  it 'includes query parameters' do
    described_class.lookup(
      token: token,
      options: {
        raw_annotatable_url: 'https://example.com/page',
        canonical_url: 'https://example.com/canonical',
        og_url: 'https://example.com/og'
      }
    )
    expect(HTTParty).to have_received(:get).with(
      "https://api.genius.com/?access_token=#{token}" \
      '&raw_annotatable_url=https://example.com/page' \
      '&canonical_url=https://example.com/canonical' \
      '&og_url=https://example.com/og'
    )
  end
end

describe Genius::WebPages, ' .lookup without token' do
  before do
    allow(Genius::Auth).to receive(:authorized?).and_return(false)
  end

  it 'returns nil' do
    expect(described_class.lookup(token: nil)).to be_nil
  end
end

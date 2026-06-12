# frozen_string_literal: true

require 'genius/api'

describe Genius::WebPages do
  describe '.lookup' do
    context 'with valid token' do
      let(:token) { 'a' * 64 }
      let(:response_body) do
        {
          'meta' => { 'status' => 200 },
          'response' => { 'web_page' => { 'id' => 1, 'url' => 'https://example.com' } }
        }.to_json
      end
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

      before do
        allow(Genius::Errors).to receive(:validate_token)
        allow(HTTParty).to receive(:get).and_return(mock_response)
      end

      it 'returns web page data as a hash' do
        result = described_class.lookup(token: token)
        aggregate_failures do
          expect(result).to be_a(Hash)
          expect(result.dig('meta', 'status')).to eq(200)
        end
      end

      it 'sends a GET request to the API root' do
        described_class.lookup(token: token)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/?access_token=#{token}"
        )
      end
    end

    context 'with URL variants' do
      let(:token) { 'a' * 64 }
      let(:response_body) { { 'meta' => { 'status' => 200 }, 'response' => { 'web_page' => { 'id' => 1, 'url' => 'https://example.com' } } }.to_json }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:url_options) do
        {
          raw_annotatable_url: 'https://example.com/page',
          canonical_url: 'https://example.com/canonical',
          og_url: 'https://example.com/og'
        }
      end
      let(:expected_url) do
        "https://api.genius.com/?access_token=#{token}" \
          '&raw_annotatable_url=https://example.com/page' \
          '&canonical_url=https://example.com/canonical' \
          '&og_url=https://example.com/og'
      end

      before do
        allow(Genius::Errors).to receive(:validate_token)
        allow(HTTParty).to receive(:get).and_return(mock_response)
      end

      it 'includes query parameters in the request' do
        described_class.lookup(token: token, options: url_options)
        expect(HTTParty).to have_received(:get).with(expected_url)
      end
    end

    context 'without token' do
      before do
        allow(Genius::Auth).to receive(:authorized?).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.lookup(token: nil)).to be_nil
      end
    end
  end
end

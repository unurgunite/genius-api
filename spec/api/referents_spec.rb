# frozen_string_literal: true

require 'genius/api'

describe Genius::Referents do
  describe '.referents' do
    context 'with valid token' do
      let(:token) { 'a' * 64 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 }, 'response' => { 'referents' => [] } }.to_json }

      before { allow(HTTParty).to receive(:get).and_return(mock_response) }

      it 'returns referents as a hash' do
        result = described_class.referents(token: token)
        aggregate_failures do
          expect(result).to be_a(Hash)
          expect(result.dig('meta', 'status')).to eq(200)
        end
      end

      it 'sends a GET request to the referents endpoint' do
        described_class.referents(token: token)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/referents?access_token=#{token}"
        )
      end
    end

    context 'with options' do
      let(:token) { 'a' * 64 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 }, 'response' => { 'referents' => [] } }.to_json }

      before { allow(HTTParty).to receive(:get).and_return(mock_response) }

      it 'includes query parameters' do
        described_class.referents(token: token, options: { per_page: 5, page: 2 })
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/referents?access_token=#{token}&per_page=5&page=2"
        )
      end
    end

    context 'with both web_page and song_id' do
      let(:token) { 'a' * 64 }

      before { allow(Genius::Errors).to receive(:validate_token) }

      it 'raises ArgumentError' do
        expect do
          described_class.referents(token: token, options: { web_page: 1, song_id: 2 })
        end.to raise_error(ArgumentError)
      end
    end

    context 'without token' do
      before do
        allow(Genius::Auth).to receive(:authorized?).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.referents(token: nil)).to be_nil
      end
    end
  end
end

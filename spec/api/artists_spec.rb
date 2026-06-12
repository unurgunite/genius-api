# frozen_string_literal: true

require 'genius/api'

describe Genius::Artists do
  describe '.artists' do
    context 'with valid data' do
      let(:token) { 'a' * 64 }
      let(:artist_id) { 16_764 }
      let(:response_body) do
        {
          'meta' => { 'status' => 200 },
          'response' => { 'artist' => { 'id' => artist_id, 'name' => 'Test Artist' } }
        }.to_json
      end
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

      before { allow(HTTParty).to receive(:get).and_return(mock_response) }

      it 'returns artist data as a hash' do
        result = described_class.artists(token: token, id: artist_id)
        aggregate_failures do
          expect(result).to be_a(Hash)
          expect(result.dig('meta', 'status')).to eq(200)
        end
      end

      it 'sends a GET request to the artists endpoint' do
        described_class.artists(token: token, id: artist_id)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/artists/#{artist_id}?access_token=#{token}"
        )
      end
    end

    context 'with nil id' do
      let(:token) { 'a' * 64 }
      let(:artist_id) { 16_764 }

      before { allow(Genius::Errors).to receive(:validate_token) }

      it 'raises ArgumentError' do
        expect { described_class.artists(token: token, id: nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.artists_songs' do
    context 'with valid data' do
      let(:token) { 'a' * 64 }
      let(:artist_id) { 16_764 }
      let(:response_body) do
        {
          'meta' => { 'status' => 200 },
          'response' => { 'songs' => [{ 'id' => 1, 'title' => 'Song 1' }] }
        }.to_json
      end
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

      before { allow(HTTParty).to receive(:get).and_return(mock_response) }

      it 'returns songs data as a hash' do
        result = described_class.artists_songs(token: token, id: artist_id)
        aggregate_failures do
          expect(result).to be_a(Hash)
          expect(result.dig('meta', 'status')).to eq(200)
        end
      end

      it 'sends a GET request to the artists songs endpoint' do
        described_class.artists_songs(token: token, id: artist_id)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/artists/#{artist_id}?access_token=#{token}"
        )
      end
    end

    context 'with sort option' do
      let(:token) { 'a' * 64 }
      let(:artist_id) { 16_764 }
      let(:response_body) { { 'meta' => { 'status' => 200 } }.to_json }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

      before { allow(HTTParty).to receive(:get).and_return(mock_response) }

      it 'includes sort parameter' do
        described_class.artists_songs(token: token, id: artist_id, options: { sort: 'popularity' })
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/artists/#{artist_id}?access_token=#{token}&sort=popularity"
        )
      end
    end

    context 'with invalid sort' do
      let(:token) { 'a' * 64 }
      let(:artist_id) { 16_764 }

      before { allow(Genius::Errors).to receive(:validate_token) }

      it 'raises ArgumentError' do
        expect do
          described_class.artists_songs(token: token, id: artist_id, options: { sort: 'invalid' })
        end.to raise_error(ArgumentError)
      end
    end

    context 'with negative per_page' do
      let(:token) { 'a' * 64 }
      let(:artist_id) { 16_764 }

      before { allow(Genius::Errors).to receive(:validate_token) }

      it 'raises ArgumentError' do
        expect do
          described_class.artists_songs(token: token, id: artist_id, options: { per_page: -1 })
        end.to raise_error(ArgumentError)
      end
    end

    context 'with negative page' do
      let(:token) { 'a' * 64 }
      let(:artist_id) { 16_764 }

      before { allow(Genius::Errors).to receive(:validate_token) }

      it 'raises ArgumentError' do
        expect do
          described_class.artists_songs(token: token, id: artist_id, options: { page: -1 })
        end.to raise_error(ArgumentError)
      end
    end

    context 'without token' do
      let(:artist_id) { 16_764 }

      before do
        allow(Genius::Auth).to receive(:authorized?).and_return(false)
      end

      it 'returns nil' do
        expect(described_class.artists_songs(token: nil, id: artist_id)).to be_nil
      end
    end
  end
end

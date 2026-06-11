# frozen_string_literal: true

require "rspec"
require "genius/api"

describe Genius::Artists do
  let(:token) { "a" * 64 }
  let(:artist_id) { 16_764 }
  let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

  before do
    allow(HTTParty).to receive(:get).and_return(mock_response)
  end

  describe ".artists" do
    let(:response_body) do
      {
        "meta" => { "status" => 200 },
        "response" => { "artist" => { "id" => artist_id, "name" => "Test Artist" } }
      }.to_json
    end

    context "when a valid token and id are provided" do
      it "returns artist data as a hash" do
        result = described_class.artists(token: token, id: artist_id)
        expect(result).to be_a(Hash)
        expect(result.dig("meta", "status")).to eq(200)
      end

      it "sends a GET request to the artists endpoint" do
        described_class.artists(token: token, id: artist_id)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/artists/#{artist_id}?access_token=#{token}"
        )
      end
    end

    context "when id is nil" do
      it "raises ArgumentError" do
        expect { described_class.artists(token: token, id: nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe ".artists_songs" do
    let(:response_body) do
      {
        "meta" => { "status" => 200 },
        "response" => { "songs" => [{ "id" => 1, "title" => "Song 1" }] }
      }.to_json
    end

    context "when a valid token and id are provided" do
      it "returns songs data as a hash" do
        result = described_class.artists_songs(token: token, id: artist_id)
        expect(result).to be_a(Hash)
        expect(result.dig("meta", "status")).to eq(200)
      end

      it "sends a GET request to the artists songs endpoint" do
        described_class.artists_songs(token: token, id: artist_id)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/artists/#{artist_id}?access_token=#{token}"
        )
      end
    end

    context "when options include sort" do
      it "includes sort parameter" do
        described_class.artists_songs(token: token, id: artist_id, options: { sort: "popularity" })
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/artists/#{artist_id}?access_token=#{token}&sort=popularity"
        )
      end

      context "with an invalid sort value" do
        it "raises ArgumentError" do
          expect {
            described_class.artists_songs(token: token, id: artist_id, options: { sort: "invalid" })
          }.to raise_error(ArgumentError)
        end
      end
    end

    context "when per_page is negative" do
      it "raises ArgumentError" do
        expect {
          described_class.artists_songs(token: token, id: artist_id, options: { per_page: -1 })
        }.to raise_error(ArgumentError)
      end
    end

    context "when page is negative" do
      it "raises ArgumentError" do
        expect {
          described_class.artists_songs(token: token, id: artist_id, options: { page: -1 })
        }.to raise_error(ArgumentError)
      end
    end

    context "when token is nil and Auth is not authorized" do
      before do
        allow(Genius::Auth).to receive(:authorized?).and_return(false)
      end

      it "returns nil" do
        expect(described_class.artists_songs(token: nil, id: artist_id)).to be_nil
      end
    end
  end
end

# frozen_string_literal: true

require "rspec"
require "genius/api"

describe Genius::Referents do
  let(:token) { "a" * 64 }
  let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
  let(:response_body) { { "meta" => { "status" => 200 }, "response" => { "referents" => [] } }.to_json }

  before do
    allow(HTTParty).to receive(:get).and_return(mock_response)
  end

  describe ".referents" do
    context "when a valid token is provided" do
      it "returns referents as a hash" do
        result = described_class.referents(token: token)
        expect(result).to be_a(Hash)
        expect(result.dig("meta", "status")).to eq(200)
      end

      it "sends a GET request to the referents endpoint" do
        described_class.referents(token: token)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/referents?access_token=#{token}"
        )
      end
    end

    context "when options are provided" do
      it "includes query parameters" do
        described_class.referents(token: token, options: { per_page: 5, page: 2 })
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/referents?access_token=#{token}&per_page=5&page=2"
        )
      end
    end

    context "when both web_page and song_id are provided" do
      it "raises ArgumentError" do
        expect {
          described_class.referents(token: token, options: { web_page: 1, song_id: 2 })
        }.to raise_error(ArgumentError)
      end
    end

    context "when token is nil and Auth is not authorized" do
      before do
        allow(Genius::Auth).to receive(:authorized?).and_return(false)
      end

      it "returns nil" do
        expect(described_class.referents(token: nil)).to be_nil
      end
    end
  end
end

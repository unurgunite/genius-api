# frozen_string_literal: true

require "rspec"
require "genius/api"

describe Genius::Search do
  let(:token) { "a" * 64 }
  let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

  describe ".search" do
    let(:response_body) do
      {
        "meta" => { "status" => 200 },
        "response" => {
          "hits" => [
            { "result" => { "title" => "Song A" } },
            { "result" => { "title" => "Song B" } }
          ]
        }
      }.to_json
    end

    before do
      allow(HTTParty).to receive(:get).and_return(mock_response)
    end

    context "when a valid token and query are provided" do
      it "returns search results as a hash" do
        result = described_class.search(token: token, query: "Ariana Grande")
        expect(result).to be_a(Hash)
        expect(result.dig("meta", "status")).to eq(200)
      end

      it "sends a GET request to the search endpoint" do
        described_class.search(token: token, query: "Ariana Grande")
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/search?q=Ariana Grande&access_token=#{token}"
        )
      end
    end

    context "when search_by is provided" do
      it "returns filtered results" do
        result = described_class.search(token: token, query: "test", search_by: "title")
        expect(result).to contain_exactly("Song A", "Song B")
      end
    end

    context "when token is nil and Auth is not authorized" do
      before do
        allow(Genius::Auth).to receive(:authorized?).and_return(false)
      end

      it "returns nil" do
        expect(described_class.search(token: nil, query: "test")).to be_nil
      end
    end

    context "when query is nil" do
      it "sends a request with nil query" do
        described_class.search(token: token, query: nil)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/search?q=&access_token=#{token}"
        )
      end
    end
  end
end

# frozen_string_literal: true

require "rspec"
require "genius/api"

describe Genius::Songs do
  let(:token) { "a" * 64 }
  let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
  let(:song_id) { 294_649 }

  describe ".songs" do
    let(:response_body) do
      {
        "meta" => { "status" => 200 },
        "response" => { "song" => { "id" => song_id, "title" => "Test Song" } }
      }.to_json
    end

    before do
      allow(HTTParty).to receive(:get).and_return(mock_response)
    end

    context "when a valid token and song_id are provided" do
      it "returns song data as a hash" do
        result = described_class.songs(token: token, song_id: song_id)
        expect(result).to be_a(Hash)
        expect(result.dig("response", "song", "id")).to eq(song_id)
      end

      it "sends a GET request to the songs endpoint" do
        described_class.songs(token: token, song_id: song_id)
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/songs/#{song_id}?access_token=#{token}"
        )
      end
    end

    context "when combine is true" do
      let(:response_body) do
        {
          "meta" => { "status" => 200 },
          "response" => { "song" => { "id" => song_id } }
        }.to_json
      end
      let(:scripts) do
        (0..16).map { |i| "<script>var x = #{i};</script>" } +
          ["<script>window.__PRELOADED_STATE__ = JSON.parse('{\\\"lyrics\\\":\\\"test lyrics\\\"}');</script>"]
      end
      let(:html_body) do
        "<html><head></head><body>#{scripts.join}</body></html>"
      end

      before do
        allow(HTTParty).to receive(:get).with("https://genius.com/songs/#{song_id}")
                                        .and_return(html_body)
      end

      it "fetches lyrics page and includes lyrics in the response" do
        result = described_class.songs(token: token, song_id: song_id, combine: true)
        expect(result).to be_a(Hash)
        expect(result).to have_key("lyrics")
        expect(result["lyrics"]).to have_key("lyrics")
      end
    end

    context "when token is nil and Auth is not authorized" do
      before do
        allow(Genius::Auth).to receive(:authorized?).and_return(false)
      end

      it "returns nil" do
        expect(described_class.songs(token: nil, song_id: song_id)).to be_nil
      end
    end
  end

  describe ".get_lyrics" do
    let(:html_body) do
      <<~HTML
        <html>
          <body>
            <div class="Lyrics__Container-sc-1ynbvzw-6 YYrds">
              <p>Test lyrics content</p>
            </div>
          </body>
        </html>
      HTML
    end

    before do
      allow(HTTParty).to receive(:get).and_return(html_body)
    end

    it "extracts lyrics from the page" do
      result = described_class.get_lyrics(song_id)
      expect(result).to eq("Test lyrics content")
    end

    context "when song_id is nil" do
      it "raises ArgumentError" do
        expect { described_class.get_lyrics(nil) }.to raise_error(ArgumentError)
      end
    end
  end
end

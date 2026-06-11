# frozen_string_literal: true

require "rspec"
require "genius/api"

describe Genius::Annotations do
  let(:token) { "a" * 64 }
  let(:annotation_id) { 10_225_840 }
  let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
  let(:response_body) { { "meta" => { "status" => 200 } }.to_json }

  before do
    allow(HTTParty).to receive(:get).and_return(mock_response)
    allow(HTTParty).to receive(:post).and_return(mock_response)
    allow(HTTParty).to receive(:put).and_return(mock_response)
    allow(HTTParty).to receive(:delete).and_return(mock_response)
  end

  describe ".annotations" do
    context "with http_verb 'get'" do
      it "sends a GET request" do
        described_class.annotations(id: annotation_id, action: nil, token: token, http_verb: "get")
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/annotations/#{annotation_id}?access_token=#{token}"
        )
      end

      it "returns parsed JSON" do
        result = described_class.annotations(id: annotation_id, action: nil, token: token, http_verb: "get")
        expect(result).to be_a(Hash)
      end
    end

    context "with http_verb 'post'" do
      it "sends a POST request" do
        described_class.annotations(
          id: annotation_id, action: nil, token: token, http_verb: "post",
          options: { markdown: "test", raw_annotatable_url: "https://example.com" }
        )
        expect(HTTParty).to have_received(:post)
      end
    end

    context "with http_verb 'put'" do
      it "sends a PUT request" do
        described_class.annotations(id: annotation_id, action: nil, token: token, http_verb: "put")
        expect(HTTParty).to have_received(:put)
      end

      context "with action 'upvote'" do
        it "sends a PUT request to the upvote endpoint" do
          described_class.annotations(id: annotation_id, action: "upvote", token: token, http_verb: "put")
          expect(HTTParty).to have_received(:put).with(
            "https://api.genius.com/annotations/#{annotation_id}/upvote?access_token=#{token}"
          )
        end
      end

      context "with action 'downvote'" do
        it "sends a PUT request to the downvote endpoint" do
          described_class.annotations(id: annotation_id, action: "downvote", token: token, http_verb: "put")
          expect(HTTParty).to have_received(:put).with(
            "https://api.genius.com/annotations/#{annotation_id}/downvote?access_token=#{token}"
          )
        end
      end

      context "with action 'unvote'" do
        it "sends a PUT request to the unvote endpoint" do
          described_class.annotations(id: annotation_id, action: "unvote", token: token, http_verb: "put")
          expect(HTTParty).to have_received(:put).with(
            "https://api.genius.com/annotations/#{annotation_id}/unvote?access_token=#{token}"
          )
        end
      end

      context "with an invalid action" do
        it "raises ArgumentError" do
          expect {
            described_class.annotations(id: annotation_id, action: "invalid", token: token, http_verb: "put")
          }.to raise_error(ArgumentError)
        end
      end
    end

    context "with http_verb 'delete'" do
      it "sends a DELETE request" do
        described_class.annotations(id: annotation_id, action: nil, token: token, http_verb: "delete")
        expect(HTTParty).to have_received(:delete).with(
          "https://api.genius.com/annotations/#{annotation_id}?access_token=#{token}"
        )
      end
    end

    context "when action is provided with a non-PUT verb" do
      it "raises ArgumentError" do
        expect {
          described_class.annotations(id: annotation_id, action: "upvote", token: token, http_verb: "get")
        }.to raise_error(ArgumentError, /only PUT accepts/)
      end
    end
  end

  describe "private methods" do
    describe ".post_payload" do
      it "builds a JSON payload from options" do
        payload = described_class.send(:post_payload, options: {
          markdown: "hello **world!**",
          raw_annotatable_url: "https://example.com",
          fragment: "test",
          before_html: "<p>",
          after_html: "</p>",
          canonical_url: "https://example.com/canonical",
          og_url: "https://example.com/og",
          title: "Test Page"
        })

        parsed = JSON.parse(payload)
        expect(parsed.dig("annotation", "body", "markdown")).to eq("hello **world!**")
        expect(parsed.dig("referent", "raw_annotatable_url")).to eq("https://example.com")
        expect(parsed.dig("web_page", "title")).to eq("Test Page")
      end
    end
  end
end

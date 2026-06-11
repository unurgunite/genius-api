# frozen_string_literal: true

require "rspec"
require "genius/api"

describe Genius::Errors do
  let(:valid_token) { "a" * 64 }
  let(:short_token) { "short_token" }
  let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }

  describe Genius::Errors::GeniusExceptionSuperClass do
    it "is a subclass of StandardError" do
      expect(described_class.superclass).to eq(StandardError)
    end
  end

  describe Genius::Errors::TokenError do
    subject(:error) { described_class.new }

    it "has default message" do
      expect(error.msg).to include("Invalid token")
    end

    it "has default exception type" do
      expect(error.exception_type).to eq("token_error")
    end

    context "when method_name is provided" do
      subject(:error) { described_class.new(method_name: "Genius::Auth.authorized?") }

      it "includes method_name in the message" do
        expect(error.msg).to include("Genius::Auth.authorized?")
      end
    end
  end

  describe Genius::Errors::LyricsNotFoundError do
    subject(:error) { described_class.new }

    it "has default message" do
      expect(error.msg).to eq("Lyrics not found in current session. Retrying...")
    end

    it "has default exception type" do
      expect(error.exception_type).to eq("invalid_lyrics")
    end
  end

  describe Genius::Errors::PageNotFound do
    subject(:error) { described_class.new }

    it "has default message" do
      expect(error.msg).to eq("Page not found. Try again with another response")
    end

    it "has default exception type" do
      expect(error.exception_type).to eq("page_not_found")
    end

    describe ".page_not_found?" do
      it "returns true if html contains 'Page not found'" do
        html = Nokogiri::HTML("<html><body>Page not found</body></html>")
        expect(described_class.page_not_found?(html)).to be true
      end

      it "returns false if html does not contain 'Page not found'" do
        html = Nokogiri::HTML("<html><body>OK</body></html>")
        expect(described_class.page_not_found?(html)).to be false
      end
    end
  end

  describe ".validate_token" do
    context "when token is nil" do
      it "raises TokenError" do
        expect { described_class.validate_token(nil) }.to raise_error(Genius::Errors::TokenError)
      end
    end

    context "when token size is not 64" do
      it "raises TokenError" do
        expect { described_class.validate_token(short_token) }.to raise_error(Genius::Errors::TokenError)
      end
    end

    context "when token is valid and API responds with 200" do
      let(:response_body) { { "meta" => { "status" => 200 } }.to_json }

      before do
        allow(HTTParty).to receive(:get).and_return(mock_response)
      end

      it "does not raise an error" do
        expect { described_class.validate_token(valid_token) }.not_to raise_error
      end
    end

    context "when token is valid but API responds with non-200" do
      let(:response_body) { { "meta" => { "status" => 401 } }.to_json }

      before do
        allow(HTTParty).to receive(:get).and_return(mock_response)
      end

      it "raises TokenError" do
        expect { described_class.validate_token(valid_token) }.to raise_error(Genius::Errors::TokenError)
      end
    end
  end

  describe ".error_handle" do
    context "when token is nil" do
      it "raises TokenError with a specific message" do
        expect { described_class.error_handle(nil) }.to raise_error(Genius::Errors::TokenError)
      end
    end

    context "when token size is not 64" do
      it "raises TokenError" do
        expect { described_class.error_handle(short_token) }.to raise_error(Genius::Errors::TokenError)
      end
    end

    context "when token is valid" do
      let(:response_body) { { "meta" => { "status" => 200 } }.to_json }

      before do
        allow(HTTParty).to receive(:get).and_return(mock_response)
      end

      it "returns true" do
        expect(described_class.error_handle(valid_token)).to be true
      end
    end
  end
end

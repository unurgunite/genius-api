# frozen_string_literal: true

require "rspec"
require "dotenv/load"
require "genius/api"

describe Genius::Auth do
  let!(:auth) { described_class }
  # @todo Change .env to .env.local
  let(:token) { ENV["TOKEN"] }

  describe ".authorized?" do
    context "when a valid token is provided" do
      before do
        auth.login = token
      end

      it "returns true" do
        expect(auth.authorized?).to be true
      end
    end

    context "when an invalid token is provided" do
      it "returns false" do
        auth.logout!
        auth.login = "invalid_token"
        expect(auth.authorized?).to be false
      end
    end
  end

  describe ".logout!" do
    it "sets the token to nil" do
      auth.logout!
      expect(auth.instance_variable_get(:@token)).to be_nil
    end
  end
end

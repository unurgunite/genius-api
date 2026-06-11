# frozen_string_literal: true

require "rspec"
require "genius/api"

describe Genius::Auth do
  let(:auth) { described_class }
  let(:valid_token) { "a" * 64 }

  before do
    auth.logout!
  end

  describe ".authorized?" do
    context "when a valid token is provided" do
      before do
        allow(Genius::Errors).to receive(:validate_token)
        auth.login = valid_token
      end

      it "returns true" do
        expect(auth.authorized?).to be true
      end
    end

    context "when an invalid token is provided" do
      before do
        allow(Genius::Errors).to receive(:validate_token).and_raise(Genius::Errors::TokenError.new)
      end

      it "returns false" do
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

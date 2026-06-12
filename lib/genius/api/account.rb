# frozen_string_literal: true

module Genius
  # +Genius::Account+ module provides methods to work with Genius account
  module Account
    class << self
      # Returns account info for the authenticated user.
      #
      # @param [String?] token Token to access https://api.genius.com.
      # @return [Hash, nil]
      def account(token: nil)
        return if token.nil? && !Auth.authorized?.nil?

        Errors.validate_token(token) unless token.nil?

        response = HTTParty.get("https://api.genius.com/account?access_token=#{token_ext(token)}").body
        JSON.parse(response)
      end

      alias me account

      Genius::Errors::DynamicRescue.rescue(Module.nesting[1])
    end
  end
end

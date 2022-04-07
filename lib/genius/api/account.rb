# frozen_string_literal: true

module Genius
  # +Genius::Account+ module provides methods to work with Genius account
  module Account
    class << self
      # +Genius::Account.account+        -> value
      #
      # An alias to {Genius::Account.account me} method
      #
      # @param [String] token Token to access https://api.genius.com.
      # @raise [TokenError] if +token+ or +Genius::Auth.token+ are invalid.
      # @return [Hash]
      # @return [nil] if TokenError exception raised.
      # This method is a standard Genius API {request}[https://docs.genius.com/#search-h2] to get
      # account info. Output +JSON+ is translated to Hash structure to make it easy to work with account fields.
      #
      # @example
      #     Genius::Auth.login="yuiaYqbncErCVwItjQxFspNWUZLhGpXrPbkvgbgHSEKJRAlToamzMfdOeDB"
      #     Genius::Account.account #=> {"meta"=>{"status"=>200}, "response"=>{"user"=>{...}}}
      # @todo somehow refactor 50/52 exceptions
      def account(token: nil)
        return if token.nil? && !Auth.authorized?.nil?

        Errors.error_handle(token) unless token.nil?
        response = HTTParty.get("https://api.genius.com/account?access_token=#{token_ext(token)}").body

        JSON.parse(response)
      end

      alias me account

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

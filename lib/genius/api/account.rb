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
      # @raise [CloudflareError] if Cloudflare is not responding.
      # @raise [TokenError] if +token+ or +Genius::Auth.token+ are invalid.
      # @return [Hash]
      # @return [nil] if CloudflareError, TokenError exception raised.
      # This method is a standard Genius API {request}[https://docs.genius.com/#search-h2] to get
      # account info. Output +JSON+ is translated to Hash structure to make it easy to work with account fields.
      # You can also access to some fields of output hash with +field+ param, which is +nil+ by default. For e.g.,
      #
      # @example
      #     Genius::Account.account(field: "name") #=> "Foo Bar"
      #
      # Due to the nesting of a hash there could be multiple keys with the same name, so method will
      # return an array of values, but if multiple values are the same, method will return
      # value only once, without storing it in array. For e.g.,
      #
      # @example
      #     Genius::Account.account(field: "id") #=> [100033, 234411]
      #     Genius::Account.account(field: "url") #=> "https://genius.com/"
      #
      # @example
      #     Genius::Auth.login="yuiaYqbncErCVwItjQxFspNWUZLhGpXrPbkvgbgHSEKJRAlToamzMfdOeDB"
      #     Genius::Account.account #=> {"meta"=>{"status"=>200}, "response"=>{"user"=>{...}}}
      #
      # There is a +prettify+ parameter to prettify output hash. It could be called also with +field+ param,
      # for e.g.:
      #
      #     Genius::Account.account(prettify: true) #=>
      #       {"meta"=>{"status"=>200},
      #        "response"=>
      #         {"user"=>
      #          {"about_me"=>{"dom"=>{"tag"=>"root"}},
      #           ...
      #          }}
      #
      # But not every output values would be able to be prettified. For e.g.,
      #
      #     Genius::Account.account(field: "interactions", prettify: true) #=> { "following" => false }
      def account(token: nil)
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?
        response = HTTParty.get("https://api.genius.com/account?access_token=#{token_ext(token)}").body
        raise CloudflareError.new(response: response) unless JSON.parse(response).is_a? Hash

        JSON.parse(response)
      end

      alias me account

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

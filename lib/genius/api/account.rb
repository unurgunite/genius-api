# frozen_string_literal: true

module Genius # :nodoc:
  # +Genius::Account+ module provides methods to work with Genius account
  module Account
    class << self
      include Genius::Errors

      # +Genius::Account.me+        -> value
      # @param [String] token Token to access https://api.genius.com.
      # @param [String] field Optional param to parse output hash tree.
      # @param [Boolean] prettify Optional param to prettify output.
      # @return [nil]
      # This method is a standard Genius API {request}[https://docs.genius.com/#search-h2] to get
      # account info. Output +JSON+ is translated to Hash structure to make it easy to work with account fields.
      # You can also access to some fields of output hash with +field+ param, which is +nil+ by default. For e.g.,
      # @example
      #     Genius::Account.me(field: "name") #=> "Foo Bar"
      #
      # Due to the nesting of a hash there could be multiple keys with the same name, so method will
      # return an array of values, but if multiple values are the same, method will return
      # value only once, without storing it in array. For e.g.,
      # @example
      #     Genius::Account.me(field: "id") #=> [100033, 234411]
      #     Genius::Account.me(field: "url") #=> "https://genius.com/"
      #
      # @example
      #     Genius::Auth.login="yuiaYqbncErCVwItjQxFspNWUZLhGpXrPbkvgbgHSEKJRAlToamzMfdOeDB"
      #     Genius::Account.me #=> {"meta"=>{"status"=>200}, "response"=>{"user"=>{...}}}
      #
      # There is a +prettify+ parameter to prettify output hash. It could be called also with +field+ param,
      # for e.g.:
      # @example
      #     Genius::Account.me(prettify: true) #=>
      #       {"meta"=>{"status"=>200},
      #        "response"=>
      #         {"user"=>
      #          {"about_me"=>{"dom"=>{"tag"=>"root"}},
      #           ...
      #          }}
      #
      # But not every output values would be able to be prettified. For e.g.,
      # @example
      #     Genius::Account.me(field: "interactions", prettify: true) #=> { "following" => false }
      def me(token = nil, field: nil, prettify: false)
        Genius::Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        response = HTTParty.get("https://api.genius.com/account?access_token=#{token || Genius::Auth.send(:token)}").body
        raise GeniusDown.new(response: response) unless JSON.parse(response).is_a? Hash

        account = JSON.parse(response)
        if field && prettify
          pp account.deep_find(field)
        elsif prettify
          pp account
        elsif field
          account.deep_find(field)
        else
          account
        end
      rescue GeniusDown, TokenError, TokenMissing => e
        puts "Error description: #{e.msg}"
        puts "Exception type: #{e.exception_type}"
      end

      alias account me
    end
  end
end

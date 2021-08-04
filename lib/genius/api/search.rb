# frozen_string_literal: true

module Genius
  # +Genius::Search+ module provides methods to work with Genius search database
  module Search
    class << self
      # +Genius::Search.search+     -> value
      #
      # @param [String] token Token to access https://api.genius.com.
      # @param [String] query Search query.
      # @param [Object] search_by Optional parameter to search by key in output +JSON+.
      # @return [String] if +search_by+ is +TrueClass+
      # @return [Hash] if +search_by+ is +FalseClass+
      # @return [nil] if CloudflareError, TokenError exception raised.
      # This method is a standard Genius API {method}[https://docs.genius.com/#search-h2] and it is
      # needed to send a request to the server and get information about artists, tracks and everything
      # else that may be inside the response body. According to https://docs.genius.com/#search-h2, token
      # is required to be in response, but you can use this method without use of it! =)
      #
      # @example
      #     Genius::Search.search(query: "Ariana Grande") #=> {..., "full_title"=>" thank u, next by Ariana Grande", ...}
      #
      # Also, you can use this method with +search_by+ param, which is needed to search interested
      # data through returned +JSON+. It uses +deep_find+ extension under the hood.
      #
      # @example
      #     Genius::Search.search(query: "Bones", search_by: "title") #=> ["Dirt", "HDMI", "RestInPeace", "Sodium"]
      #
      # @see #deep_find
      def search(token: nil, query: nil, search_by: nil)
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?

        response = HTTParty.get("#{Api::RESOURCE}/search?q=#{query}&access_token=#{token_ext(token)}").body
        search = JSON.parse(response)
        search_by ? search.deep_find(search_by) : search
      end

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

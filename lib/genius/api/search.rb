# frozen_string_literal: true

module Genius # :nodoc:
  # +Genius::Search+ module provides methods to work with Genius search database
  module Search
    class << self
      include Genius::Errors

      # +Genius::Search.search+     -> value
      # @param [String] token Token to access https://api.genius.com.
      # @param [String] query Search query.
      # @param [Object] search_by Optional parameter to search by key in output +JSON+.
      # @return [String] if +search_by+ is +TrueClass+
      # @return [Hash] if +search_by+ is +FalseClass+
      # @return [nil] if GeniusDown, TokenError, TokenMissing exception raised
      # This method is a standard Genius API {method}[https://docs.genius.com/#search-h2] and it is
      # needed to send a request to the server and get information about artists, tracks and everything
      # else that may be inside the response body. According to https://docs.genius.com/#search-h2, token
      # is required to be in response, but you can use this method without use of it! =)
      #
      # *Examples:*
      #     Genius::Search.search(query: "Ariana Grande") #=> {..., "full_title"=>" thank u, next by Ariana Grande", ...}
      #
      # Also, you can use this method with +search_by+ param, which is needed to search interested
      # data through returned +JSON+. It uses +deep_find+ extension under the hood.
      #
      # *Examples:*
      #     Genius::Search.search(query: "Bones", search_by: "title") #=> ["Dirt", "HDMI", "RestInPeace", "Sodium"]
      #
      # See Hash#deep_find
      def search(token: nil, query: nil, search_by: nil)
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?

        response = HTTParty.get("https://api.genius.com/search?q=#{query}&access_token=#{token || Genius::Auth.__send__(:token)}").body
        search = JSON.parse(response)
        search_by ? search.deep_find(search_by) : search
      rescue GeniusDown, TokenError, TokenMissing => e
        puts "Error description: #{e.msg}"
        puts "Exception type: #{e.exception_type}"
        nil
      end
    end
  end
end

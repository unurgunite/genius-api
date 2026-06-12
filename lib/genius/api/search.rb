# frozen_string_literal: true

module Genius
  # +Genius::Search+ module provides methods to work with Genius search database
  module Search
    class << self
      # Searches Genius for songs, artists, and other content. Optionally filters results by key using +deep_find+.
      #
      # @param [String?] token Token to access https://api.genius.com.
      # @param [String?] query Search query.
      # @param [String?] search_by Key to filter results with {Hash#deep_find}.
      # @return [Hash, String, nil]
      def search(token: nil, query: nil, search_by: nil)
        return if token.nil? && !Auth.authorized?.nil?

        Errors.validate_token(token) unless token.nil?

        response = HTTParty.get("#{Api::RESOURCE}/search?q=#{query}&access_token=#{token_ext(token)}").body
        search = JSON.parse(response)
        search_by ? search.deep_find(search_by) : search
      end

      Genius::Errors::DynamicRescue.rescue(Module.nesting[1])
    end
  end
end

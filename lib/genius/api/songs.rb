# frozen_string_literal: true

module Genius # :nodoc:
  # +Genius::Songs+ module provides methods to work with songs (lyrics/descriptions/etc.)
  module Songs
    class << self
      include Genius::Errors

      # <b>EXPERIMENTAL FEATURE</b>
      #
      # +Genius::Songs.songs+     -> value
      # @param [String] token Token to access https://api.genius.com.
      # @param [Integer] song_id Song id.
      # @param [Boolean] lyrics Print lyrics.
      # @param [FalseClass] annotations
      # @return [nil]
      # This method provides info about song by its id. It is not the same with +Genius::Search.search+ method,
      # because it modify a +JSON+ only for concrete song id, not for whole search database, which is returned
      # in +Genius::Search.search+
      #
      # *Examples:*
      #
      #     Genius::Songs.search_songs(song_id: 294649) #=> {""}
      #
      def songs(token: nil, song_id: nil, lyrics: true, annotations: false)
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?
        response = HTTParty.get("https://api.genius.com/songs/#{song_id}?access_token=#{token || Genius::Auth.__send__(:token)}").body
        search = JSON.parse(response)
        search
      rescue GeniusDown, TokenError, TokenMissing => e
        puts "Error description: #{e.msg}"
        puts "Exception type: #{e.exception_type}"
      end

      # :nodoc:
      # +Genius::Songs.get_lyrics+      -> hash
      # @param [Integer] song_id Song id.
      # @return [Hash]
      def get_lyrics(song_id)
        Hash song_id
      end
    end
  end
end

# frozen_string_literal: true

module Genius
  # +Genius::Songs+ module provides methods to work with songs (lyrics/descriptions/etc.)
  module Songs
    class << self
      include Genius::Errors

      # Returns song data by ID. Optionally merges lyrics from the Genius page when +combine+ is +true+.
      #
      # @param [String?] token Token to access https://api.genius.com.
      # @param [Integer?] song_id ID of the song.
      # @param [Boolean] combine If +true+, fetches and merges lyrics into the response.
      # @return [Hash, String, nil]
      def songs(token: nil, song_id: nil, combine: false)
        return if token.nil? && !Auth.authorized?.nil?

        Errors.validate_token(token) unless token.nil?

        response = HTTParty.get("#{Api::RESOURCE}/songs/#{song_id}?access_token=#{token_ext(token)}").body
        response = JSON.parse response
        combine && song_id ? merge_lyrics(song_id, response) : response
      end

      private

      # Fetches the Genius HTML page for a song and merges lyrics into the API response.
      #
      # @private
      # @param [Integer] song_id ID of the song.
      # @param [Hash] response Original API response hash.
      # @raise [Errors::PageNotFound] if the song page is not found.
      # @raise [Errors::LyricsNotFoundError] if lyrics cannot be parsed.
      # @return [Hash, String]
      def merge_lyrics(song_id, response)
        output_html = Nokogiri::HTML(HTTParty.get("https://genius.com/songs/#{song_id}"))
        raise Errors::PageNotFound if Errors::PageNotFound.page_not_found?(output_html)

        response['lyrics'] = parse_preloaded_state(output_html)
        response
      rescue Errors::LyricsNotFoundError
        retry
      rescue Errors::PageNotFound => e
        "Error description: #{e.msg}\nException type: #{e.exception_type}"
      end

      # Extracts the preloaded state JSON from the Genius page HTML.
      #
      # @private
      # @param [Object] output_html Parsed Nokogiri HTML document.
      # @raise [Errors::LyricsNotFoundError] if the preloaded state script is not found.
      # @return [Hash]
      def parse_preloaded_state(output_html)
        unformed_json = output_html.css('script')[17]
                                   .text.match(/window\.__PRELOADED_STATE__\s=\sJSON.parse\('(?<json>(?:.+?))'\);/)
        raise Errors::LyricsNotFoundError if unformed_json.nil?

        JSON.parse(unformed_json[:json].unescape)
      end

      public

      # Extracts lyrics as plain text from the Genius song page.
      #
      # @param [Integer] song_id ID of the song.
      # @raise [ArgumentError] if +song_id+ is nil.
      # @raise [NoMethodError]
      # @return [String]
      def get_lyrics(song_id)
        raise ArgumentError, '`song_id` should be not blank!' if song_id.nil?

        response = HTTParty.get("https://genius.com/songs/#{song_id}")
        document = Nokogiri::HTML(response)
        # @todo: something wrong with lyrics attribute value
        lyrics_path = document.xpath("//*[@class='Lyrics__Container-sc-1ynbvzw-6 YYrds']")
        lyrics_path.at_css('p').content
      rescue NoMethodError
        retry
      end

      Genius::Errors::DynamicRescue.rescue(Module.nesting[1])
    end
  end
end

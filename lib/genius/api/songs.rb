# frozen_string_literal: true

module Genius
  # +Genius::Songs+ module provides methods to work with songs (lyrics/descriptions/etc.)
  module Songs
    class << self
      include Genius::Errors

      # +Genius::Songs.songs+     -> value
      #
      # @param [String] token Token to access https://api.genius.com.
      # @param [Integer] song_id Song id.
      # @raise [PageNotFound] if page is not found.
      # @raise [LyricsNotFound] if output JSON is nil.
      # @raise [CloudflareError] if Cloudflare is not responding.
      # @raise [TokenError] if +token+ or +Genius::Auth.token+ are invalid.
      # @return [String] the error message if +lyrics+ param is +true+.
      # @return [Hash] if +lyrics+ param is +false+.
      # @return [nil] if CloudflareError, TokenError exception raised.
      # This method provides info about song by its id. It is not the same with +Genius::Search.search+ method,
      # because it modify a +JSON+ only for concrete song id, not for whole search database, which is returned
      # in +Genius::Search.search+.
      #
      # @example
      #     Genius::Songs.songs(song_id: 294649) #=> {"some_kind_of_hash"}
      def songs(token: nil, song_id: nil, combine: false)
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?

        response = HTTParty.get("#{Api::RESOURCE}/songs/#{song_id}?access_token=#{token_ext(token)}").body
        response = JSON.parse response
        if combine
          begin
            output_html = Nokogiri::HTML(HTTParty.get("https://genius.com/songs/#{song_id}"))
            raise PageNotFound if PageNotFound.page_not_found?(output_html)

            unformed_json = output_html.css("script")[21].text.match(/window\.__PRELOADED_STATE__\s=\sJSON.parse\('(?<json>(.+?))'\);/)
            raise LyricsNotFoundError if unformed_json.nil?

            formatted_json = unformed_json[:json]
            lyrics_json = JSON.parse(formatted_json.unescape)
            response["lyrics"] = lyrics_json
            return response
          rescue LyricsNotFoundError
            retry
          rescue PageNotFound => e
            puts "Error description: #{e.msg}"
            puts "Exception type: #{e.exception_type}"
            return
          end
        end
        response
      end

      # +Genius::Songs.get_lyrics+      -> hash
      #
      # @param [Integer] song_id Song id.
      # @raise [ArgumentError] if +song_id+ is blank.
      # @return [Hash]
      # +Genius::Songs.get_lyrics+ method is used for extracting lyrics in plain text format
      def get_lyrics(song_id)
        raise ArgumentError, "`song_id` should be not blank!" if song_id.nil?

        response = HTTParty.get("https://genius.com/songs/#{song_id}")
        document = Nokogiri::HTML(response)
        lyrics_path = document.xpath("//*[@class='lyrics']")
        lyrics_path.at_css("p").content
      rescue NoMethodError
        retry
      end

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

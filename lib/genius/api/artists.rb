# frozen_string_literal: true

module Genius # :nodoc:
  # An artist is how Genius represents the creator of one or more songs (or other documents hosted on Genius). It's
  # usually a musician or group of musicians.
  module Artists
    class << self
      # +Genius::Artists.artists+                     -> Hash
      # @param [String] token Token to access https://api.genius.com.
      # @param [String] id ID of the song.
      # @return [Hash]
      # @return [nil] if GeniusDown, TokenError, TokenMissing exception raised.
      def artists(token: nil, id: nil)
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?
        raise ArgumentError, "`id` can't be nil!" if id.nil?

        response = HTTParty.get("#{Api::RESOURCE}/artists/#{id}?access_token=#{token_ext(:token)}").body
        JSON.parse(response)
      end

      # +Genius::Artists.artists_songs+               -> Hash
      # Documents (songs) for the artist specified. By default, 20 items are returned for each request.
      # @param [String] token Token to access https://api.genius.com.
      # @param [String] id ID of the song.
      # @param [Hash] options
      # @option [Integer] :per_page Number of results to return per request.
      # @option [Integer] :page Paginated offset, (e.g., +per_page=5&page=3+ returns songs 11-15).
      # @option [String] :sort +title+ (default) or +popularity+.
      # @return [Hash]
      # @return [nil] if GeniusDown, TokenError, TokenMissing exception raised.
      def artists_songs(token: nil, id: nil, options: {})
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?
        sort_values = %w[title popularity]
        unless sort_values.include?(options[:sort])
          raise ArgumentError, "`sort` can't be #{sort}. Possible values: #{sort_values.join(", ")}."
        end

        if (options[:per_page]).negative? || (options[:page]).negative?
          raise ArgumentError, "`per_page` or `page` can't be negative."
        end

        params = options_helper(options, %i[sort per_page page])

        response = HTTParty.get("#{Api::RESOURCE}/artists/#{id}?access_token=#{token_ext(token)}#{params}").body
        JSON.parse(response)
      end

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

# frozen_string_literal: true

module Genius
  # An artist is how Genius represents the creator of one or more songs (or other documents hosted on Genius). It's
  # usually a musician or group of musicians.
  module Artists
    class << self
      # +Genius::Artists.artists+                     -> Hash
      #
      # Data for a specific artist.
      #
      # @param [String] token Token to access https://api.genius.com.
      # @param [String] id ID of the song.
      # @raise [ArgumentError] if +id+ is +nil+.
      # @raise [TokenError] if +token+ or +Genius::Auth.token+ are invalid.
      # @return [Hash]
      # @return [NilClass] if TokenError exception raised.
      def artists(token: nil, id: nil)
        Auth.authorized?(method_name: "#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.validate_token(token) unless token.nil?
        raise ArgumentError, "`id` can't be nil!" if id.nil?

        response = HTTParty.get("#{Api::RESOURCE}/artists/#{id}?access_token=#{token_ext(token)}").body
        JSON.parse(response)
      end

      # +Genius::Artists.artists_songs+               -> Hash | NilClass
      #
      # Documents (songs) for the artist specified. By default, 20 items are returned for each request.
      #
      # @param [String] token Token to access https://api.genius.com.
      # @param [String] id ID of the song.
      # @param [Hash] options
      # @option options [Integer] :per_page Number of results to return per request.
      # @option options [Integer] :page Paginated offset, (e.g., +per_page=5&page=3+ returns songs 11-15).
      # @option options [String] :sort +title+ (default) or +popularity+.
      # @raise [ArgumentError] if +sort+ got incorrect value.
      # @raise [ArgumentError] if +per_page+ or +page+ are negative.
      # @raise [TokenError] if +token+ or +Genius::Auth.token+ are invalid.
      # @return [Hash]
      # @return [NilClass] if TokenError exception raised.
      def artists_songs(token: nil, id: nil, options: {})
        return if token.nil? && !Auth.authorized?.nil?

        Errors.validate_token(token) unless token.nil?

        sort_values = %w[title popularity]
        validate(sort_values, sort: options[:sort], per_page: options[:per_page], page: options[:page])

        params = options_helper(options, %i[sort per_page page])
        response = HTTParty.get("#{Api::RESOURCE}/artists/#{id}?access_token=#{token_ext(token)}#{params}").body
        JSON.parse(response)
      end

      private

      # +Genius::Artists.validate+                    -> value
      #
      # A helper method which validates some options for artists endpoint.
      #
      # @param [Array<String>] sort_values
      # @param [Hash] options
      # @return [NilClass]
      def validate(sort_values, **options)
        validate_sort(options[:sort], sort_values)
        validate_page_per_page(options[:per_page])
        validate_page_per_page(options[:page])
      end

      # +Genius::Artists.validate_sort+               -> value
      #
      # A helper method which validates sort options for artists endpoint.
      #
      # @see Artists.artists_songs
      # @param [String] sort
      # @param [Array<String>] sort_values Possible values for sort.
      # @raise [ArgumentError] if sort is invalid value.
      # @return [Object]
      def validate_sort(sort, sort_values)
        return unless sort && !sort_values.include?(sort)

        raise ArgumentError, "`sort` can't be #{sort}. Possible values: #{sort_values.join(", ")}."
      end

      # +Genius::Artists.validate_page_per_page+      -> value
      #
      # A helper method which validates per_page or page option for artists endpoint.
      #
      # @see Artists.artists_songs
      # @param [Integer] page_per_page
      # @raise [ArgumentError] if per_page or page does not exist or negative.
      # @return [NilClass]
      def validate_page_per_page(page_per_page)
        raise ArgumentError, "`per_page` or `page` can't be negative." if page_per_page&.negative?
      end

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

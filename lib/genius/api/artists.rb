# frozen_string_literal: true

module Genius
  # An artist is how Genius represents the creator of one or more songs (or other documents hosted on Genius). It's
  # usually a musician or group of musicians.
  module Artists
    class << self
      # Data for a specific artist.
      #
      # @param [String?] token Token to access https://api.genius.com.
      # @param [Integer?] id ID of the artist.
      # @raise [ArgumentError] if +id+ is nil.
      # @return [Hash, nil]
      def artists(token: nil, id: nil)
        Auth.authorized?(method_name: "#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.validate_token(token) unless token.nil?
        raise ArgumentError, "`id` can't be nil!" if id.nil?

        response = HTTParty.get("#{Api::RESOURCE}/artists/#{id}?access_token=#{token_ext(token)}").body
        JSON.parse(response)
      end

      # Songs for the artist specified. By default 20 items per request.
      #
      # @param [String?] token Token to access https://api.genius.com.
      # @param [Integer?] id ID of the artist.
      # @param [Hash] options Optional query params: +:sort+, +:per_page+, +:page+.
      # @return [Hash, nil]
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

      # Validates sort, per_page, and page options for artists endpoint.
      #
      # @private
      # @param [Array] sort_values Allowed sort values.
      # @param [Object] options Options with +:sort+, +:per_page+, +:page+.
      # @return [void]
      def validate(sort_values, **options)
        validate_sort(options[:sort], sort_values)
        validate_page_per_page(options[:per_page])
        validate_page_per_page(options[:page])
      end

      # Validates the sort option against allowed values.
      #
      # @private
      # @param [String?] sort Sort value to validate.
      # @param [Array] sort_values Allowed sort values.
      # @raise [ArgumentError] if +sort+ is not in +sort_values+.
      # @return [void]
      def validate_sort(sort, sort_values)
        return unless sort && !sort_values.include?(sort)

        raise ArgumentError, "`sort` can't be #{sort}. Possible values: #{sort_values.join(', ')}."
      end

      # Validates that per_page or page is not negative.
      #
      # @private
      # @param [Integer?] page_per_page Value to validate.
      # @raise [ArgumentError] if value is negative.
      # @return [void]
      def validate_page_per_page(page_per_page)
        raise ArgumentError, "`per_page` or `page` can't be negative." if page_per_page&.negative?
      end

      Genius::Errors::DynamicRescue.rescue(Module.nesting[1])
    end
  end
end

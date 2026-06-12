# frozen_string_literal: true

module Genius
  # Referents are the sections of a piece of content to which annotations are
  # attached. Each referent is associated with a web page or a song and may
  # have one or more annotations. Referents can be searched by the document
  # they are attached to or by the user that created them. When a new
  # annotation is created either a referent is created with it or that
  # annotation is attached to an existing referent.
  module Referents
    class << self
      # Endpoint of the resource
      ENDPOINT = "#{Api::RESOURCE}/referents".freeze
      # Referents by content item or user. Pass only one of +:song_id+ and +:web_page+.
      #
      # @param [String?] token Token to access https://api.genius.com.
      # @param [Hash] options Options: +:created_by_id+, +:text_format+, +:web_page_id+,
      #   +:song_id+, +:per_page+, +:page+.
      # @raise [ArgumentError] if both +:song_id+ and +:web_page+ are present.
      # @return [Hash, nil]
      def referents(token: nil, options: {})
        return if token.nil? && !Auth.authorized?.nil?

        Errors.validate_token(token) unless token.nil?
        if options.key?(:web_page) && options.key?(:song_id)
          raise ArgumentError, 'You may pass only one of song_id and web_page_id, not both!'
        end

        params = options_helper(options, %i[created_by_id text_format per_page page])

        response = HTTParty.get("#{ENDPOINT}?access_token=#{token_ext(token)}#{params}").body
        JSON.parse(response)
      end

      Genius::Errors::DynamicRescue.rescue(Module.nesting[1])
    end
  end
end

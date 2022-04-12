# frozen_string_literal: true

module Genius
  # Referents are the sections of a piece of content to which annotations are attached. Each referent is associated with
  # a web page or a song and may have one or more annotations. Referents can be searched by the document they are
  # attached to or by the user that created them. When a new annotation is created either a referent is created with
  # it or that annotation is attached to an existing referent.
  module Referents
    class << self
      # Endpoint of the resource
      ENDPOINT = "#{Api::RESOURCE}/referents"
      # +Genius::Referents.referents+                 -> Hash
      #
      # @param [Hash] options
      # @option options [Integer] :created_by_id ID of a user to get referents for.
      # @option options [String] :text_format Format for text bodies related to the document. One or more of +dom+, +plain+,
      #     and +html+, separated by commas (defaults to +dom+). See details of each option
      #     {here}[https://docs.genius.com/#response-format-h1].
      # @option options [Integer] :web_page_id ID of a web page to get referents for
      # @option options [Integer] :song_id ID of a song to get referents for
      # @option options [Integer] :per_page Number of results to return per request
      # @option options [Integer] :page Paginated offset, (e.g., <code>per_page=5&page=3</code> returns songs 11-15)
      # @raise [ArgumentError] if +song_id+ and +web_page+ are presented in the same scope.
      # @raise [TokenError] if +token+ or +Genius::Auth.token+ are invalid.
      # @return [Hash]
      # Referents by content item or user responsible for an included annotation.
      # You may pass only one of song_id and web_page_id, not both.
      def referents(token: nil, options: {})
        return if token.nil? && !Auth.authorized?.nil?

        Errors.error_handle(token) unless token.nil?
        if options.key?(:web_page) && options.key?(:song_id)
          raise ArgumentError, "You may pass only one of song_id and web_page_id, not both!"
        end

        params = options_helper(options, %i[created_by_id text_format per_page page])

        response = HTTParty.get("#{ENDPOINT}?access_token=#{token_ext(token)}#{params}").body
        JSON.parse(response)
      end

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

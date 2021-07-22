# frozen_string_literal: true

module Genius # :nodoc:
  # Referents are the sections of a piece of content to which annotations are attached. Each referent is associated with
  # a web page or a song and may have one or more annotations. Referents can be searched by the document they are
  # attached to or by the user that created them. When a new annotation is created either a referent is created with
  # it or that annotation is attached to an existing referent.
  module Referents
    class << self
      include Genius::Errors
      ENDPOINT = "https://api.genius.com/referents"
      # Genius::Referents.referents                   -> HTTParty::Response
      # @param [Hash] options
      # @option [Integer] :created_by_id ID of a user to get referents for.
      # @option [String] :text_format Format for text bodies related to the document. One or more of +dom+, +plain+, and +html+, separated by commas (defaults to +dom+). See details of each option {here}[https://docs.genius.com/#response-format-h1].
      # @option [Integer] :web_page_id ID of a web page to get referents for
      # @option [Integer] :song_id ID of a song to get referents for
      # @option [Integer] :per_page Number of results to return per request
      # @option [Integer] :page Paginated offset, (e.g., <code>per_page=5&page=3</code> returns songs 11-15)
      # @raise [ArgumentError] if `id` is nil.
      # @return [Hash]
      # Referents by content item or user responsible for an included annotation.
      # You may pass only one of song_id and web_page_id, not both.
      def referents(token: nil, options: {})
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?
        if options.key?(:web_page) && options.key?(:song_id)
          raise ArgumentError, "You may pass only one of song_id and web_page_id, not both!"
        end

        params = ""
        o = %i[created_by_id text_format per_page page]
        options.each_key do |k, v|
          params.insert(params.length, "&#{k}=#{v}") if o.include? k
        end

        response = HTTParty.get("#{ENDPOINT}?access_token=#{token || Genius::Auth.__send__(:token)}#{params}").body
        JSON.parse(response)
      end
    end
  end
end

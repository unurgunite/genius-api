# frozen_string_literal: true

module Genius
  # An annotation is a piece of content about a part of a document. The document may be a song (hosted on Genius) or a
  # web page (hosted anywhere). The part of a document that an annotation is attached to is called a referent.
  module Annotations
    class << self
      # Data for a specific annotation. Supports GET, POST, PUT, DELETE verbs with optional voting actions.
      #
      # @param [Integer] id ID of the annotation.
      # @param [String?] action Action for PUT request: +nil+, +upvote+, +downvote+, or +unvote+.
      # @param [String?] token Token to access https://api.genius.com.
      # @param [String] http_verb HTTP verb: +get+, +post+, +put+, +delete+.
      # @param [Hash] options Options for POST/PUT payload.
      # @raise [ArgumentError] if +action+ is set for non-PUT request.
      # @return [Hash, nil]
      def annotations(id:, action:, token:, http_verb: 'get', options: {})
        return if token.nil? && !Auth.authorized?.nil?

        Errors.validate_token(token) unless token.nil?
        raise ArgumentError, 'only PUT accepts `action` param' if http_verb != 'put' && !action.nil?

        JSON.parse(request(id: id, action: action, token: token, http_verb: http_verb, options: options).body)
      end

      private

      # Sends an HTTP request based on the verb and returns the raw response.
      #
      # @private
      # @param [Integer] id ID of the annotation.
      # @param [String?] action Action for PUT request.
      # @param [String?] token Token to access https://api.genius.com.
      # @param [String] http_verb HTTP verb.
      # @param [Hash] options Options for POST/PUT payload.
      # @raise [ArgumentError] if HTTP verb is invalid.
      # @return [HTTParty::Response]
      def request(id:, action:, token:, http_verb:, options:)
        case http_verb
        when 'get' then HTTParty.get("#{Api::RESOURCE}/annotations/#{id}?access_token=#{token_ext(token)}")
        when 'post' then HTTParty.post("#{Api::RESOURCE}/annotations/#{id}?access_token=#{token_ext(token)}",
                                       body: post_payload(options: options))
        when 'put' then put_request(id: id, action: action, token: token, options: options)
        when 'delete' then HTTParty.delete("#{Api::RESOURCE}/annotations/#{id}?access_token=#{token_ext(token)}")
        else raise ArgumentError, 'Something bad happened...'
        end
      end

      # Sends a PUT request with optional voting action.
      #
      # @private
      # @param [Integer] id ID of the annotation.
      # @param [String?] action Action: +nil+, +upvote+, +downvote+, or +unvote+.
      # @param [String?] token Token to access https://api.genius.com.
      # @param [Hash] options Options for PUT payload.
      # @raise [ArgumentError] if +action+ is invalid.
      # @return [HTTParty::Response]
      def put_request(id:, action:, token:, options:)
        case action
        when nil then HTTParty.put("#{Api::RESOURCE}/annotations/#{id}/#{action}?access_token=#{token_ext(token)}",
                                   body: post_payload(options: options))
        when 'upvote', 'downvote', 'unvote' then HTTParty.put("#{Api::RESOURCE}/annotations/#{id}/#{action}?access_token=#{token_ext(token)}")
        else
          actions = %w[upvote downvote unvote]
          raise ArgumentError,
                "Invalid value for `action` param. Allowed values are: #{actions.join(', ')}"
        end
      end

      # Builds a JSON payload for POST and PUT requests from options.
      #
      # @private
      # @param [Hash] options Options containing +:markdown+, +:raw_annotatable_url+, +:fragment+, etc.
      # @return [String]
      def post_payload(options: {})
        {
          annotation: { body: { markdown: options[:markdown] } },
          referent: {
            raw_annotatable_url: options[:raw_annotatable_url],
            fragment: options[:fragment],
            context_for_display: { before_html: options[:before_html], after_html: options[:after_html] }
          },
          web_page: { canonical_url: options[:canonical_url], og_url: options[:og_url], title: options[:title] }
        }.to_json
      end

      Genius::Errors::DynamicRescue.rescue(Module.nesting[1])
    end
  end
end

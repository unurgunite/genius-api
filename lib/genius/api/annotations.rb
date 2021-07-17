# frozen_string_literal: true

module Genius
  # An annotation is a piece of content about a part of a document. The document may be a song (hosted on Genius) or a
  # web page (hosted anywhere). The part of a document that an annotation is attached to is called a referent.
  module Annotations
    include Genius::Errors

    class << self
      # Genius::Annotations.annotations               -> true or false
      # @param [String] token
      # @param [String] http_verb
      # @return [nil] if GeniusDown, TokenError, TokenMissing exceptions raised
      # Genius::Annotations.annotations method
      ENDPOINT = "https://api.genius.com/annotations"

      def annotations(id:, action:, token: nil, http_verb: "get")
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?
        raise ArgumentError, "only PUT accepts 'action' arg" if http_verb != "put" && !action.nil?

        # actions = %w[upvote downvote unvote]

        case http_verb
        when "get"
          HTTParty.get("#{ENDPOINT}/#{id}?access_token=#{token || Genius::Auth.__send__(:token)}")
        when "post"
          HTTParty.post("#{ENDPOINT}/#{id}?access_token=#{token || Genius::Auth.__send__(:token)}", body: post_payload)
        when "put"
          # conditionals
        when "delete"
          nil
        else
          "Something happened"
        end
      rescue GeniusDown, TokenError, TokenMissing => e
        puts "Error description: #{e.msg}"
        puts "Exception type: #{e.exception_type}"
        nil
      end

      def post_payload(markdown: nil, raw_annotatable_url: nil, fragment: nil, before_html: nil, after_html: nil, canonical_url: nil, og_url: nil, title: nil)
        {
          annotation: {
            body: {
              markdown: markdown
            }
          },
          referent: {
            raw_annotatable_url: raw_annotatable_url,
            fragment: fragment,
            context_for_display: {
              before_html: before_html,
              after_html: after_html
            }
          },
          web_page: {
            canonical_url: canonical_url,
            og_url: og_url,
            title: title
          }
        }.to_json
      end
    end
  end
end

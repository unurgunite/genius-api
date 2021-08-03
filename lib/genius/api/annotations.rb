# frozen_string_literal: true

module Genius
  # An annotation is a piece of content about a part of a document. The document may be a song (hosted on Genius) or a
  # web page (hosted anywhere). The part of a document that an annotation is attached to is called a referent.
  module Annotations
    class << self
      # +Genius::Annotations.annotations+              -> true or false
      #
      # @param [Object] id Identification of annotations resource.
      # @param [Object] action Action to do during PUT request. Possible actions: nil, upvote, downvote, unvote.
      # @param [String] token Token to access https://api.genius.com.
      # @param [String (frozen)] http_verb HTTP verb for request. Possible verbs: get, post, put, delete.
      # @param [Hash] options Options for PUT response.
      # @option options [String] :markdown The text for the note, in
      #     {markdown}[https://help.github.com/articles/github-flavored-markdown/]
      # @option options [String] :raw_annotatable_url The original URL of the page.
      # @option options [String] :fragment The highlighted fragment.
      # @option options [String] :before_html The HTML before the highlighted fragment (prefer up to 200 characters).
      # @option options [String] :after_html The HTML after the highlighted fragment (prefer up to 200 characters).
      # @option options [String] :canonical_url The href property of the <code>&lt;link rel="canonical"&gt;</code> tag
      #     on the page. Including it will help make sure newly created annotation appear on the correct page.
      # @option options [String] :og_url The content property of the <code>&lt;meta property="og:url"&gt;</code> tag on
      #     the page. Including it will help make sure newly created annotation appear on the correct page.
      # @option options [String] :title The title of the page.
      # @raise [ArgumentError] if `action` got incorrect value.
      # @return [nil] if CloudflareError, TokenError, TokenMissing exceptions raised.
      # Genius::Annotations.annotations method
      # GET /annotations/:id
      # Data for a specific annotation.
      #
      # @example Example usage
      #     Genius::Annotations.annotations(id: 10225840)
      #
      # POST /annotations
      # Requires scope: create_annotation
      #
      # Creates a new annotation on a public web page. The returned value will be the new annotation object, in the
      # same form as would be returned by GET /annotation/:id with the new annotation's ID. Requires JSON payload.
      # @example Example Payload
      #     {
      #       "annotation": {
      #         "body": {
      #           "markdown": "hello **world!**"
      #         }
      #       },
      #       "referent": {
      #         "raw_annotatable_url": "http://seejohncode.com/2014/01/27/vim-commands-piping/",
      #         "fragment": "execute commands",
      #         "context_for_display": {
      #           "before_html": "You may know that you can ",
      #           "after_html": " from inside of vim, with a vim command:"
      #         }
      #       },
      #       "web_page": {
      #         "canonical_url": null,
      #         "og_url": null,
      #         "title": "Secret of Mana"
      #       }
      #     }
      #
      # Example usage
      #     Genius::Annotations.annotation(id:, http_verb: "post", markdown: "Foo **Bar**", raw_annotatable_url: "https://example.com")
      # will reproduce JSON object via +Genius::Annotations.post_payload+ method. According to last example it will
      # return
      #     {
      #       annotation: {
      #         body: {
      #           markdown: "Foo **Bar**"
      #         }
      #       },
      #       referent: {
      #         raw_annotatable_url: "https://example.com",
      #         fragment: null,
      #         context_for_display: {
      #           before_html: null,
      #           after_html: null
      #         }
      #       },
      #       web_page: {
      #         canonical_url: null,
      #         og_url: null,
      #         title: null
      #       }
      #     }
      #
      # There is a full list of possible params:
      # <ul>
      # <li>annotation
      # <ul>
      # <li>body
      # <ul>
      # <li>markdown - The text for the note, in
      # <a href="https://help.github.com/articles/github-flavored-markdown/">markdown</a>
      # <i>(Required)</i>
      # </li>
      # </ul>
      # </li>
      # </ul>
      # </li>
      # <li>referent
      # <ul>
      # <li>raw_annotatable_url - The original URL of the page <i>(Required)</i></li>
      # </ul>
      # <ul>
      # <li>fragment - The highlighted fragment <i>(Required)</i></li>
      # </ul>
      # <li>context_for_display
      # <ul>
      # <li>before_html - The HTML before the highlighted fragment (prefer up to 200 characters)
      # </li>
      # </ul>
      # <ul>
      # <li>after_html - The HTML after the highlighted fragment (prefer up to 200 characters)</li>
      # </ul>
      # </li>
      # <li>web_page <i>At least one required</i>
      # <ul>
      # <li>canonical_url - The href property of the
      # <code>
      # &lt;link rel="canonical"&gt;
      # </code>
      # tag on the page. Including it will help make sure newly created annotation appear on the correct page
      # </li>
      # </ul>
      # <ul>
      # <li>og_url - The content property of the <code>
      # &lt;meta property="og:url"&gt;
      # </code> tag on the page. Including it will help make sure newly created annotation appear on the correct
      # page
      # </li>
      # </ul>
      # <ul>
      # <li>title - The title of the page</li>
      # </ul>
      # </li>
      # </ul>
      #
      # PUT /annotations/:id
      # Requires scope: manage_annotation
      # Updates an annotation created by the authenticated user. Accepts the same parameters as POST /annotation above.
      #
      # @example Example usage
      #     Genius::Annotations.annotations(id: 10225840, http_verb: "put")
      #
      # DELETE /annotations/:id
      # Requires scope: manage_annotation
      # Deletes an annotation created by the authenticated user.
      #
      # @example Example usage
      #     Genius::Annotations.annotations(id: 10225840, http_verb: "delete")
      #
      # PUT /annotations/:id/upvote
      # Requires scope: vote
      # Votes positively for the annotation on behalf of the authenticated user.
      #
      # @example Example usage
      #     Genius::Annotations.annotations(id: 10225840, http_verb: "put", action: "upvote")
      #
      # PUT /annotations/:id/downvote
      # Requires scope: vote
      # Votes negatively for the annotation on behalf of the authenticated user.
      #
      # @example Example usage
      #     Genius::Annotations.annotations(id: 10225840, http_verb: "put", action: "vote")
      #
      # PUT /annotations/:id/unvote
      # Requires scope: vote
      # Removes the authenticated user's vote (up or down) for the annotation.
      #
      # @example Example usage
      #     Genius::Annotations.annotations(id: 10225840, http_verb: "put", action: "vote")
      def annotations(id:, action: nil, token: nil, http_verb: "get", options: {})
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?
        raise ArgumentError, "only PUT accepts `action` param" if http_verb != "put" && !action.nil?

        actions = %w[upvote downvote unvote]

        case http_verb
        when "get"
          HTTParty.get("#{Api::RESOURCE}/annotations/#{id}?access_token=#{token_ext(token)}")
        when "post"
          HTTParty.post("#{Api::RESOURCE}/annotations/#{id}?access_token=#{token_ext(token)}",
                        body: post_payload(options: options))
        when "put"
          case action
          when nil
            HTTParty.put("#{Api::RESOURCE}/annotations/#{id}/#{action}?access_token=#{token_ext(token)}",
                         body: post_payload(options: options))
          when "upvote", "downvote", "unvote"
            HTTParty.put("#{Api::RESOURCE}/annotations/#{id}/#{action}?access_token=#{token_ext(token)}")
          else
            raise ArgumentError, "Invalid value for `action` param. Allowed values are: #{actions.join(", ")}"
          end
        when "delete"
          HTTParty.delete("#{Api::RESOURCE}/annotations/#{id}?access_token=#{token_ext(token)}")
        else
          raise ArgumentError, "Something bad happened..."
        end
      end

      # +Genius::Annotations.post_payload+              -> value
      #
      # @param [Hash] options Options for PUT response.
      # @option options [String] :markdown The text for the note, in
      #     {markdown}[https://help.github.com/articles/github-flavored-markdown/]
      # @option options [String] :raw_annotatable_url The original URL of the page.
      # @option options [String] :fragment The highlighted fragment.
      # @option options [String] :before_html The HTML before the highlighted fragment (prefer up to 200 characters).
      # @option options [String] :after_html The HTML after the highlighted fragment (prefer up to 200 characters).
      # @option options [String] :canonical_url The href property of the <code>&lt;link rel="canonical"&gt;</code> tag
      #     on the page. Including it will help make sure newly created annotation appear on the correct page.
      # @option options [String] :og_url The content property of the <code>&lt;meta property="og:url"&gt;</code> tag on
      #     the page. Including it will help make sure newly created annotation appear on the correct page.
      # @option options [String] :title The title of the page.
      # @return [Object]
      def post_payload(options: {})
        {
          annotation: {
            body: {
              markdown: options[:markdown]
            }
          },
          referent: {
            raw_annotatable_url: options[:raw_annotatable_url],
            fragment: options[:fragment],
            context_for_display: {
              before_html: options[:before_html],
              after_html: options[:after_html]
            }
          },
          web_page: {
            canonical_url: options[:canonical_url],
            og_url: options[:og_url],
            title: options[:title]
          }
        }.to_json
      end

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

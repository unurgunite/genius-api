# frozen_string_literal: true

module Genius
  # A web page is a single, publicly accessible page to which annotations may be attached. Web pages map 1-to-1 with
  # unique, canonical URLs.
  module WebPages
    class << self
      # +Genius::WebPages.lookup+         -> value
      #
      # Information about a web page retrieved by the page's full URL (including protocol). The returned data includes
      # Genius's ID for the page, which may be used to look up associated referents with
      # the {/referents}[https://docs.genius.com/#/referents-index] endpoint.
      #
      # Data is only available for pages that already have at least one annotation.
      #
      # Provide as many of the following variants of the URL as possible:
      # @param [Hash] options
      # @option options [String] :raw_annotatable_url The URL as it would appear in a browser.
      # @option options [String] :canonical_url The URL as specified by an appropriate <code><link></code> tag
      #     in a page's <code><head></code>.
      # @option options [String] :og_url The URL as specified by an <code>og:url <meta></code> tag in a page's
      #     <code><head></code>
      # @return [Hash]
      def lookup(token: nil, options: {})
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?

        params = options_helper(options, %i[raw_annotatable_url canonical_url og_url])

        response = HTTParty.get("#{Api::RESOURCE}/?access_token=#{token_ext(token)}#{params}")
        JSON.parse(response)
      end

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

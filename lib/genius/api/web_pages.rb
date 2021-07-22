# frozen_string_literal: true

module Genius # :nodoc:
  # A web page is a single, publicly accessible page to which annotations may be attached. Web pages map 1-to-1 with
  # unique, canonical URLs.
  module WebPages
    class << self
      # Information about a web page retrieved by the page's full URL (including protocol). The returned data includes
      # Genius's ID for the page, which may be used to look up associated referents with the
      # {/referents}[https://docs.genius.com/#/referents-index] endpoint.
      #
      # Data is only available for pages that already have at least one annotation.
      #
      # Provide as many of the following variants of the URL as possible:
      # @param [Hash] options
      # @option [String] :raw_annotatable_url The URL as it would appear in a browser.
      # @option [String] :canonical_url The URL as specified by an appropriate <code>&lt;link&gt;</code> tag in a page's
      #     <code>&lt;head&gt;</code>.
      # @option [string] :og_url The URL as specified by an <code>og:url &lt;meta&gt;</code> tag in a page's
      #     <code>&lt;head&gt;</code>
      def lookup(token: nil, options: {})
        Auth.authorized?("#{Module.nesting[1].name}.#{__method__}") if token.nil?
        Errors.error_handle(token) unless token.nil?

        params = options_helper(options, %i[raw_annotatable_url canonical_url og_url])

        HTTParty.get("#{Api::RESOURCE}/?access_token=#{token_ext(token)}#{params}")
      rescue GeniusDown, TokenError, TokenMissing => e
        puts "Error description: #{e.msg}"
        puts "Exception type: #{e.exception_type}"
        nil
      end
    end
  end
end

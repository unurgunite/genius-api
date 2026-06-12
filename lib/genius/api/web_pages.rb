# frozen_string_literal: true

module Genius
  # A web page is a single, publicly accessible page to which annotations may
  # be attached. Web pages map 1-to-1 with unique, canonical URLs.
  module WebPages
    class << self
      # Looks up a web page by URL variants and returns Genius metadata.
      #
      # @param [String?] token Token to access https://api.genius.com.
      # @param [Hash] options URL variants: +:raw_annotatable_url+, +:canonical_url+, +:og_url+.
      # @return [Hash, nil]
      def lookup(token: nil, options: {})
        return if token.nil? && !Auth.authorized?.nil?

        Errors.validate_token(token) unless token.nil?

        params = options_helper(options, %i[raw_annotatable_url canonical_url og_url])
        response = HTTParty.get("#{Api::RESOURCE}/?access_token=#{token_ext(token)}#{params}").body
        JSON.parse(response)
      end

      Genius::Errors::DynamicRescue.rescue(Module.nesting[1])
    end
  end
end

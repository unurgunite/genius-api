# frozen_string_literal: true

module Genius
  # +Genius::Auth+ module is used to authenticate users with their token. It
  # provides initialization of token instance variable.
  #
  # @example
  #     Genius::Auth.login="yuiaYqbncErCVwItjQxFspNWUZLhGpXrPbkvgbgHSEKJRAlToamzMfdOeDB"
  module Auth
    class << self
      # Sets the authentication token after validation.
      #
      # @param [String] token Token to access https://api.genius.com.
      # @raise [Genius::Errors::TokenError] if +token+ is invalid.
      # @return [String]
      def token=(token)
        Genius::Errors.validate_token(token)
        @token = token
      end

      # Checks if the current token is authorized. Returns +false+ on validation failure.
      #
      # @param [String] token Token to validate.
      # @param [String] method_name Method name for error messages.
      # @raise [Genius::Errors::TokenError]
      # @return [Boolean]
      def authorized?(token = @token, method_name: "#{Module.nesting[1].name}.#{__method__}")
        Errors.validate_token(token, method_name: method_name)
      rescue Genius::Errors::TokenError
        false
      else
        true
      end

      # Revokes the current session by setting the token to +nil+.
      #
      # @return [nil]
      def logout!
        @token = nil unless @token.nil?
      end

      alias login= token=

      Genius::Errors::DynamicRescue.rescue(Module.nesting[1])
    end
  end
end

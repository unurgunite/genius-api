# frozen_string_literal: true

module Genius
  # +Genius::Auth+ module is used to authenticate users with their token. It
  # provides initialization of token instance variable.
  #
  # @example
  #     Genius::Auth.login="yuiaYqbncErCVwItjQxFspNWUZLhGpXrPbkvgbgHSEKJRAlToamzMfdOeDB"
  module Auth
    class << self
      # +Genius::Auth.token=+                         -> true ot false
      #
      # +Genius::Auth.token=+ is a setter which handles all possible exceptions
      # under the hood during authentication. It means that you should never use
      # +token=+ method unless you actually know that your credentials are
      # valid (not recommended).
      #
      # @param [String] token Token to access https://api.genius.com.
      # @raise [TokenError] if +token+ is invalid.
      # @return [String]
      # @see .authorized?
      def token=(token)
        p token
        p 1
        Genius::Errors.validate_token(token)
        @token = token
      end

      # +Genius::Auth.authorized?+                    -> true or false
      #
      # +authorized?+ method checks if user in current session is authorized.
      #
      # @param [NilClass|String] method_name Optional param to pass method name
      #     where exception was raised.
      # @raise [TokenError] if +token+ is invalid.
      # @return [Boolean]
      # @todo somehow detect exceptions as boolean type
      def authorized?(token = @token, method_name: "#{Module.nesting[1].name}.#{__method__}")
        Errors.validate_token(token, method_name: method_name)
      rescue Genius::Errors::TokenError
        false
      else
        true
      end

      # +Genius::Auth.logout!+                        -> NilClass
      #
      # +logout!+ method modifies a +token+ object and revoke session by
      # setting +nil+ to the +token+.
      #
      # @return [NilClass]
      def logout!
        @token = nil unless token.nil?
      end

      alias login= token=

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

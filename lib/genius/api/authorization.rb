# frozen_string_literal: true

module Genius
  # +Genius::Auth+ module is used to authenticate users with their token. It provides initialization
  # of token instance variable
  #
  # @example
  #     Genius::Auth.login="yuiaYqbncErCVwItjQxFspNWUZLhGpXrPbkvgbgHSEKJRAlToamzMfdOeDB"
  module Auth
    class << self
      # +Genius::Auth.token=(token)+                  -> true ot false
      #
      # @param [String] token Token to access https://api.genius.com.
      # @raise [TokenError] if +token+ is invalid.
      # @return [String]
      # +token=+ is a setter which handles all possible exceptions under the hood during authentication. It means that
      # you should never use +token=+ method unless you actually know that your credentials are valid (not recommended).
      #
      # @see .authorized?
      def token=(token)
        Genius::Errors.error_handle(token)
        puts "Authorized!"
        @token = token
      end

      # +Genius::Auth.authorized?+                    -> true or false
      #
      # @param [nil|String] method_name Optional param to pass method name where exception was raised.
      # @raise [TokenError] if +token+ is invalid.
      # @return [Boolean]
      # +authorized?+ method checks if user in current session is authorized
      # @todo somehow detect exceptions as boolean type
      def authorized?(method_name: "#{Module.nesting[1].name}.#{__method__}")
        status = Genius::Errors.error_handle(@token, method_name: method_name)
        !status.is_a?(Genius::Errors::GeniusExceptionSuperClass)
      end

      # +Genius::Auth.logout!+                        -> nil
      #
      # @return [nil]
      # +logout!+ method modifies a +token+ object and revoke session by setting +nil+ to the +token+.
      def logout!
        @token = nil unless token.nil?
      end

      alias login= token=

      Genius::Errors::DynamicRescue.rescue(const_get(Module.nesting[1].name))
    end
  end
end

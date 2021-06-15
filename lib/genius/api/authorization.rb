# frozen_string_literal: true

module Genius # :nodoc:
  # +Genius::Auth+ module is used to authenticate users with their token. It provides initialization
  # of token instance variable
  #
  # *Examples:*
  #     Genius::Auth.login="yuiaYqbncErCVwItjQxFspNWUZLhGpXrPbkvgbgHSEKJRAlToamzMfdOeDB"
  module Auth
    class << self
      attr_writer :token

      include Genius::Errors

      # +Genius::Auth.login=(token)+         -> true ot false
      # @param [String] token Token to access https://api.genius.com.
      # @return [nil]
      # +login=+ method is a some kind of an extension for a setter +token=+ and could handle possible
      # exceptions during authentication. It means that you should never use +token=+ method unless
      # you actually know that your credentials are valid (not recommended).
      # See Auth#is_authorized?
      def login=(token)
        Errors.error_handle(token)
        puts "Authorized!"
        self.token = token
      rescue TokenError => e
        puts "Error description: #{e.msg}"
        puts "Exception type: #{e.exception_type}"
      end

      # +Genius::Auth.authorized?+           -> true or false
      # @param [nil or String] method_name Optional param to pass method name where exception was raised.
      # @return [Boolean]
      # +authorized?+ method checks if user in current session is authorized
      def authorized?(method_name = nil)
        false unless Errors.error_handle(token, method_name: method_name)
        !!token
      end

      # +Genius::Auth.logout!+               -> nil
      # @return [nil]
      # +logout!+ method modifies a +token+ object and revoke session by setting +nil+ to the +token+.
      def logout!
        self.token = nil unless token.nil?
      end

      private

      attr_reader :token
    end
  end
end

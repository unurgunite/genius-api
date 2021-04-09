# frozen_string_literal: true

require "httparty"
require "json"
require_relative "errors"

module Genius
  # module Auth is used to authenticate user with his token
  # @example
  #     Genius::Auth.login="yuiaYqbncErCVwItjQxFspNWUZLhGpXrPbkvgbgHSEKJRAlToamzMfdOeDB"
  module Auth
    class << self
      attr_writer :token
      include Genius::Errors

      # +Genius::Auth.login=(token)+         -> true ot false
      # @param [String] token
      # @return [nil]
      # +login=+ method is an extension for setter +token=+ and could handle errors during authentication.
      # It means that you should never use +token=+ method
      # See Auth#is_authorized?
      def login=(token)
        Genius::Errors.error_handle(token)
        puts "Authorized!"
        self.token = token
      rescue TokenError => e
        puts "Error description: #{e.msg}"
        puts "Exception type: #{e.exception_type}"
      end

      # +Genius::Auth.is_authorized?+        -> true or false
      # @return [Boolean]
      # module to check if user in current session was authorized
      def is_authorized?
        Genius::Errors.error_handle(self.token)
        raise TokenMissing if self.token.nil?
        !!self.token
      end

      private

      attr_reader :token
    end
  end
end

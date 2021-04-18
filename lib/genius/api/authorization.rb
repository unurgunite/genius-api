# frozen_string_literal: true

require "httparty"
require "json"
require_relative "errors"

module Genius
  # module Auth is used to authenticate users with their token
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

      # +Genius::Auth.authorized?+           -> true or false
      # @return [Boolean]
      # +authorized?+ method checks if user in current session is authorized
      def authorized?(method_name = nil)
        Genius::Errors.error_handle(token, method_name: method_name)
        !!token
      end

      private

      attr_reader :token
    end
  end
end

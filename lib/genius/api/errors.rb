# frozen_string_literal: true

module Genius
  # +Genius::Errors+ module includes custom exception classes and methods to
  # handle all errors during requests to https://api.genius.com or during
  # the work with library methods.
  #
  # @example
  #     module Genius
  #       module Foo
  #         include Genius::Errors
  #         class << self
  #           def bar(params)
  #             # body
  #           rescue TokenError => e
  #             puts "Error description: #{e.msg}"            #=> Invalid token!....
  #             puts "Error description: #{e.exception_type}" #=> token_error
  #           end
  #         end
  #       end
  #     end
  #
  # Exception classes fields provide custom message and error types
  # (+connection_error+, +token_error+, +auth_required+, etc.)
  #
  # @example
  #     begin
  #       raise TokenError.new(msg: "Message", error_type: "error_type")
  #     rescue TokenError => e
  #       puts e.message        #=> Message
  #       puts e.exception_type #=> error_type
  #     end
  #
  # There will be a standard output of each exception if there will be no
  # params provided.
  #
  # @example
  #     begin
  #       raise TokenError
  #     rescue TokenError => e
  #       puts e.message        #=> Invalid token!....
  #       puts e.exception_type #=> token_error
  #     end
  module Errors
    # Endpoint for resource.
    ENDPOINT = "#{Api::RESOURCE}/account/?access_token"

    # Abstract class to store all exception classes in a single object.
    class GeniusExceptionSuperClass < StandardError
    end

    # A +TokenError+ object provides handling error during token validation.
    # It throws error when +token+ is invalid - expired, revoked or something
    # else. To generate new token you should go to
    # https://genius.com/signup_or_login and login, then you need to create
    # new client via the link below: https://genius.com/api-clients and
    # generate new access token. Fields to create new api client can
    # be filled in as you like - there is no restrictions and standards.
    class TokenError < GeniusExceptionSuperClass
      attr_reader :msg, :exception_type, :method_name

      # @param [String (frozen)] msg Exception message.
      # @param [String (frozen)] exception_type Exception type.
      # @return [String (frozen)]
      def initialize(msg: "Invalid token. The access token provided is expired, revoked, malformed or invalid for " \
               "other reasons.", exception_type: "token_error", method_name: nil)
        @msg = if method_name.nil?
                 msg
               else
                 "#{msg} or type #{method_name}(token: \"YOUR_TOKEN\")"
               end
        @exception_type = exception_type
        super(msg)
      end
    end

    # A +LyricsNotFoundError+ object handles an exception where JSON with
    # lyrics is not found.
    class LyricsNotFoundError < GeniusExceptionSuperClass
      attr_reader :msg, :exception_type

      # @param [String (frozen)] msg Exception message.
      # @param [String (frozen)] exception_type Exception type.
      # @return [String (frozen)]
      def initialize(msg: "Lyrics not found in current session. Retrying...", exception_type: "invalid_lyrics")
        @msg = msg
        @exception_type = exception_type
        super(msg)
      end
    end

    # A +PageNotFound+ object handles an exception where response payload is
    # invalid and Genius itself or its related service returns not found.
    class PageNotFound < GeniusExceptionSuperClass
      attr_reader :msg, :exception_type

      # @param [String (frozen)] msg Exception message.
      # @param [String (frozen)] exception_type Exception type.
      # @return [String (frozen)]
      def initialize(msg: "Page not found. Try again with another response", exception_type: "page_not_found")
        @msg = msg
        @exception_type = exception_type
        super(msg)
      end

      # +Genius::Errors::PageNotFound.page_not_found?+    -> true or false
      #
      # +PageNotFound.page_not_found?+ method is used to be a predicate for
      # handling 404 error.
      #
      # @param [Object] html
      # @return [TrueClass] if genius page is not found
      # @return [FalseClass] if genius page is found
      def self.page_not_found?(html)
        html.text.match?(/Page not found/)
      end
    end

    # +Genius::Errors::DynamicRescue+ module is used to call dynamically
    # exceptions to each method in module or class, defined in
    # +Genius::Errors+ scope.
    module DynamicRescue
      class << self
        # +Genius::Errors::DynamicRescue.rescue+          -> value
        #
        # +Genius::Errors::DynamicRescue.rescue_from+ is a helper method,
        # which, according to reflection, redefine singleton method for
        # specified module, adding to it exception handler for DRY pattern.
        #
        # @todo: add docs
        #
        # @param [Object] klass Class name of structure - module/class/etc.
        # @return [Object]
        def rescue(klass)
          DynamicRescue.rescue_from klass.singleton_methods, klass, GeniusExceptionSuperClass do |e|
            "Error description: #{e.msg}\nException type: #{e.exception_type}"
          end
        end

        # @param [Object] meths List of methods to redefine.
        # @param [Object] klass Class name of structure - module/class/etc.
        # @param [Object] exception Exception class.
        # @param [Proc] handler Body of rescue block.
        # @return [Object]
        def rescue_from(meths, klass, exception, &handler)
          meths.each do |meth|
            # store the previous implementation
            old = klass.singleton_method(meth)
            # wrap it
            klass.define_singleton_method(meth) do |*args|
              old.unbind.bind(klass).call(*args)
            rescue exception => e
              handler.call(e)
            end
          end
        end
      end
    end

    class << self
      def validate_token(token, method_name: nil)
        raise TokenError, method_name: method_name if token.nil? || token.size != 64

        response = HTTParty.get("#{ENDPOINT}=#{token}").body
        status = JSON.parse(response).dig("meta", "status")
        raise TokenError, method_name: method_name unless status == 200
      end

      # +Genius::Errors.error_handle(token)+              -> true or false
      #
      # @deprecated Since 0.2.1
      # @param [String] token Token to access https://api.genius.com.
      # @param [NilClass or String] method_name Optional param to pass method
      # name where exception was raised.
      # @return [Boolean]
      #
      # @example
      #     begin
      #       Genius::Errors.validate_token(token)
      #     rescue Genius::Errors::TokenError => e
      #       puts e.message
      #       puts e.exception_type
      #     end
      # This method is necessary to handle all errors during validation.
      # +token+ param is not optional and it is needed to validate token
      # itself. +method_name+ param optional and it to passes
      # method name in error exception for dynamical error message, and
      # because of unimportance this method is
      # +nil+ by default. If you are ready to pass method, it will look like
      # this:
      #
      # @example
      #     begin
      #       Genius::Errors.error_handle(token, method_name: __method__)
      #     rescue Genius::Errors::TokenError => e
      #       puts e.message
      #       puts e.exception_type
      #     end
      def error_handle(token, method_name: nil)
        if token.nil?
          raise TokenError.new(msg: "Token is required for this method. Please, add token via " \
                                                       "`Genius::Auth.login=``token''` method and continue",
                               method_name: method_name)
        elsif token.size != 64 || check_status(token) == false
          raise TokenError, method_name: method_name
        end
        true
      end

      private

      # +Genius::Errors.check_status(token)+              -> true or false
      #
      # @deprecated Since 0.2.1
      # This method was made to check token state. Token must be 64-sized
      # string and could be validated only if response status equals 200.
      # More description in {docs}[https://docs.genius.com/] and
      # {api-clients page}[https://genius.com/api-clients] or in
      # {TokenError documentation}[Genius::Auth.TokenError].
      #
      # @private
      # @param [String] token Token to access https://api.genius.com.
      # @return [Boolean]
      #
      # @see .error_handle
      def check_status(token)
        return false if token.size != 64 || token.nil?

        response = HTTParty.get("#{ENDPOINT}=#{token}").body
        raise TokenError unless JSON.parse(response).dig("meta", "status")

        status = JSON.parse(response).dig("meta", "status")
        status == 200
      end
    end
  end
end

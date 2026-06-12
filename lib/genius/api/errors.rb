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
    ENDPOINT = "#{Api::RESOURCE}/account/?access_token".freeze

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

      # Initializes a token validation error with optional method name hint.
      #
      # @param [String] msg Error message.
      # @param [String] exception_type Error type identifier.
      # @param [String?] method_name Optional method name for user hint.
      # @return [void]
      def initialize(msg: 'Invalid token. The access token provided is expired, revoked, malformed or invalid for ' \
                          'other reasons.', exception_type: 'token_error', method_name: nil)
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

      # Initializes a lyrics-not-found error.
      #
      # @param [String] msg Error message.
      # @param [String] exception_type Error type identifier.
      # @return [void]
      def initialize(msg: 'Lyrics not found in current session. Retrying...', exception_type: 'invalid_lyrics')
        @msg = msg
        @exception_type = exception_type
        super(msg)
      end
    end

    # A +PageNotFound+ object handles an exception where response payload is
    # invalid and Genius itself or its related service returns not found.
    class PageNotFound < GeniusExceptionSuperClass
      attr_reader :msg, :exception_type

      # Initializes a page-not-found error.
      #
      # @param [String] msg Error message.
      # @param [String] exception_type Error type identifier.
      # @return [void]
      def initialize(msg: 'Page not found. Try again with another response', exception_type: 'page_not_found')
        @msg = msg
        @exception_type = exception_type
        super(msg)
      end

      # Checks if the HTML response indicates a page-not-found error.
      #
      # @param [Object] html Parsed HTML document.
      # @return [Boolean]
      def self.page_not_found?(html)
        html.text.include?('Page not found')
      end
    end

    # +Genius::Errors::DynamicRescue+ module is used to call dynamically
    # exceptions to each method in module or class, defined in
    # +Genius::Errors+ scope.
    module DynamicRescue
      class << self
        # Wraps singleton methods of +klass+ with exception handling via {DynamicRescue.rescue_from}.
        #
        # @param [Module] klass Module whose singleton methods to wrap.
        # @return [Array]
        def rescue(klass)
          DynamicRescue.rescue_from klass.singleton_methods, klass, GeniusExceptionSuperClass do |e|
            puts "Error description: #{e.msg}\nException type: #{e.exception_type}"
            # @todo make raise ExceptionKlass
          end
        end

        # Redefines each method in +meths+ on +klass+ to rescue +exception+ and yield to the block.
        #
        # @param [Array] meths Method names to wrap.
        # @param [Module] klass Module to redefine methods on.
        # @param [Module] exception Exception class to rescue.
        # @param [Proc] block Handler for rescued exceptions.
        # @raise [StandardError]
        # @return [Array]
        def rescue_from(meths, klass, exception, &)
          meths.each do |meth|
            old = klass.singleton_method(meth)
            klass.define_singleton_method(meth) do |*args, **kwargs|
              old.unbind.bind(klass).call(*args, **kwargs) # steep:ignore
            rescue exception => e
              yield(e)
            end
          end
        end
      end
    end

    class << self
      # Validates the access token by checking length and making a test request to the API.
      #
      # @param [String?] token Token to validate.
      # @param [String?] method_name Optional method name for error hints.
      # @raise [StandardError] if +token+ is nil, wrong length, or invalid.
      # @return [void]
      def validate_token(token, method_name: nil)
        raise TokenError.new(method_name: method_name) if token.nil? || token.size != 64

        response = HTTParty.get("#{ENDPOINT}=#{token}").body
        status = JSON.parse(response).dig('meta', 'status')
        raise TokenError.new(method_name: method_name) unless status == 200
      end

      # Validates token and raises on failure. Returns +true+ if valid.
      #
      # @deprecated Use {.validate_token} instead.
      # @param [String?] token Token to validate.
      # @param [String?] method_name Optional method name for error hints.
      # @raise [StandardError] if token is invalid.
      # @return [Boolean]
      def error_handle?(token, method_name: nil)
        if token.nil?
          raise TokenError.new(msg: 'Token is required for this method. Please, add token via ' \
                                    "`Genius::Auth.login=``token''` method and continue",
                               method_name: method_name)
        elsif token.size != 64 || check_status?(token) == false
          raise TokenError.new(method_name: method_name)
        end
        true
      end

      private

      # Checks if the token returns a 200 status from the API.
      #
      # @deprecated Use {.validate_token} instead.
      # @private
      # @param [String] token Token to check.
      # @raise [TokenError] if the response status is not 200.
      # @return [Boolean]
      def check_status?(token)
        return false if token.size != 64 || token.nil?

        response = HTTParty.get("#{ENDPOINT}=#{token}").body
        raise TokenError unless JSON.parse(response).dig('meta', 'status')

        status = JSON.parse(response).dig('meta', 'status')
        status == 200
      end
    end
  end
end

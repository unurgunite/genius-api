# frozen_string_literal: true

require "nokogiri"

module Genius # :nodoc:
  # +Genius::Errors+ module includes custom exception classes and methods to handle all errors during
  # requests to https://api.genius.com or during the work with library methods. All
  # exception classes, but +TokenMissing+ class, requires two fields - +msg+ and +exception_type+
  # (not +nil+ by default): +TokenMissing+ requires three fields - +msg+, +exception_type+,
  # which are not +nil+, and +method_name+, which is +nil+ by default
  # @example
  #
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
  # Exception classes fields provide custom message and error types (+connection_error+,
  # +token_error+ or +auth_required+)
  # @example
  #
  #     begin
  #       raise TokenError.new(msg: "Message", error_type: "Error type")
  #     rescue TokenError => e
  #       puts e.message        #=> Message
  #       puts e.exception_type #=> Error type
  #     end
  # There will be a standard output of each exception if there will be no params provided
  # @example
  #
  #     begin
  #       raise TokenError
  #     rescue TokenError => e
  #       puts e.message        #=> Invalid token!....
  #       puts e.exception_type #=> token_error
  #     end
  module Errors
    RESPONSE = "https://api.genius.com/account/?access_token"
    # A +TokenError+ object provides handling error during token validation
    # It throws error when +token+ is invalid - expired, revoked or something else. To generate new
    # token you should go to https://genius.com/signup_or_login and login, then you need to create new
    # client via the link below: https://genius.com/api-clients and generate new access token. Fields to create
    # new api client can be filled in as you like - there are no restrictions and standards.
    class TokenError < StandardError
      attr_reader :msg, :exception_type

      # @param [String (frozen)] msg Exception message.
      # @param [String (frozen)] exception_type Exception type.
      # @return [String (frozen)]
      def initialize(msg: "Invalid token. The access token provided is expired, revoked, malformed or invalid for other reasons.", exception_type: "token_error")
        super(message)
        @msg = msg
        @exception_type = exception_type
      end
    end

    # A +TokenMissing+ object handles unauthorized access to some requests to https://api.genius.com. There are
    # <em>voting</em>, <em>account info</em> and <em>managing annotations</em>. For other methods such
    # as scraping lyrics token is not required - scraping occurs through another api client. It throws error only when
    # user did not provide token via +Genius::Auth.login="token"+ method to get access to noted methods.
    # The best practice to store your token is storing within environment variables and access them via +ENV['TOKEN']+:
    # @example
    #     Genius::Auth.login="#{ENV['TOKEN']}"
    class TokenMissing < StandardError
      attr_reader :msg, :exception_type, :method_name

      # @param [String (frozen)] msg Exception message.
      # @param [String (frozen)] exception_type Exception type.
      # @param [nil or String] method_name Optional param to provide method name which can pass token and validate it.
      # @return [String (frozen)]
      def initialize(msg: "Token is required for this method. Please, add token via `Genius::Auth.login=``token''` method and continue", exception_type: "token_missing", method_name: nil)
        super(message)
        @msg = if method_name.nil?
                 msg
               else
                 "#{msg} or type #{method_name}(token)"
               end
        @exception_type = exception_type
      end
    end

    # <b>EXPERIMENTAL EXCEPTION</b>
    #
    # A +GeniusDown+ object handles a rare exception which appears when https://api.genius.com or
    # Genius related services are under maintenance. It uses Nokogiri under the hood. Unlike from other
    # exceptions, it is inherited from +JSON::ParserError+ class, while others - from StandardError class
    class GeniusDown < JSON::ParserError
      attr_reader :msg, :exception_type, :response

      # @param [String (frozen)] msg Exception message.
      # @param [String (frozen)] exception_type Exception type.
      # @param [nil or String] response Response to parse from request to https://api.genius.com.
      # @return [String (frozen)]
      def initialize(msg: "Be patient! Genius is down. Try again in several minutes", exception_type: "genius_api_error",
                     response: nil)
        super(message)
        @msg = if response.nil?
                 msg
               else
                 document = Nokogiri::HTML(response)
                 data = document.search('li').map(&:text).join("\n")
                 "#{msg}. Possible info:\n #{data}"
               end
        @exception_type = exception_type
      end
    end

    class << self
      # +Genius::Errors.check_status(token)+          -> true or false
      # @param [String] token Token to access https://api.genius.com.
      # @return [Boolean]
      # This method was made to check token state. Token must be 64-sized string and could be validated only if
      # response status equals 200. More description in {docs}[https://docs.genius.com/] and
      # {api-clients page}[https://genius.com/api-clients] or in
      # {TokenError documentation}(Genius::Auth.TokenError)
      # See Auth#error_handle
      def check_status(token)
        raise TokenError unless token.size == 64

        response = HTTParty.get("#{RESPONSE}=#{token}").body
        raise TokenError unless JSON.parse(response).dig("meta", "status")

        status = JSON.parse(response).dig("meta", "status")
        status == 200
      end

      # +Genius::Errors.error_handle(token)+          -> true or false
      # @param [String] token Token to access https://api.genius.com.
      # @param [nil or String] method_name Optional param to pass method name where exception was raised.
      # @return [Boolean]
      # @example
      #     begin
      #       Genius::Errors.error_handle(token)
      #     rescue Genius::Errors.TokenError => e
      #       puts e.message
      #       puts e.exception_type
      #     end
      # This method is necessary to handle all errors during validation. +token+ param is not optional and
      # it is needed to validate token itself. +method_name+ param optional and it to passes
      # method name in error exception for dynamical error message, and because of unimportance this method is
      # +nil+ by default. If you are ready to pass method, it will look like this:
      # @example
      #     begin
      #       Genius::Errors.error_handle(token, __method__) # __method__ macro returns method name, so it is nice
      #                                                      # to have dynamic variable value
      #     rescue Genius::Errors.TokenMissing => e
      #       puts e.message
      #       puts e.exception_type
      #     end
      def error_handle(token, method_name: nil)
        raise TokenMissing.new(method_name: method_name) if token.nil?
        raise TokenError unless token.size == 64
        raise TokenError unless check_status(token)
      end
    end
  end
end

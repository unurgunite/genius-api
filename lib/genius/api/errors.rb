# frozen_string_literal: true

# Genius base module to handle library-based errors
module Genius
  # Module +Genius::Errors+ includes custom exception classes and methods to handle all errors during
  # requests to https://api.genius.com or during the work with library methods. All
  # exception classes requires two fields – +msg+ and +exception_type+ (not +nil+ by default).
  # @example
  #
  #    module Genius
  #      module Foo
  #        include Genius::Errors
  #        class << self
  #          def bar(params)
  #            # body
  #          rescue TokenError => e
  #            puts "Error description: #{e.msg}"            #=> Invalid token!....
  #            puts "Error description: #{e.exception_type}" #=> token_invalid
  #          end
  #         end
  #       end
  #     end
  #
  # Exception classes fields provide custom message and error types (+connection_error+ or +token_error+)
  # @example
  #
  #     begin
  #       raise TokenError.new "Message", "Error type"
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
  #       puts e.exception_type #=> token_invalid
  #     end
  module Errors
    RESPONSE = "https://api.genius.com/account/?access_token"
    # A +TokenError+ object provides handling error during token validation
    # It throws error when +token+ is invalid – expired, revoked or something else. To generate new
    # token you should go to https://genius.com/signup_or_login and login, then you need to create new
    # client via the link below: https://genius.com/api-clients and generate new access token. Fields to create
    # new api client can be filled in as you like – there are no restrictions and standards.
    class TokenError < StandardError
      attr_reader :msg, :exception_type

      def initialize(msg = "Invalid token. The access token provided is expired, revoked, malformed or invalid for other reasons.", exception_type = "token_invalid")
        super(message)
        @msg = msg
        @exception_type = exception_type
      end
    end

    # A +TokenMissing+ object handles unauthorized access to some requests to https://api.genius.com. There are
    # <em>voting</em>, <em>account info</em> and <em>managing annotations</em>. For other methods such
    # as scraping lyrics token is not required – scraping occurs through another api client. It throws error only when
    # user did not provide token via +Genius::Auth.login="token"+ method to get access to noted methods.
    # The best practice to store your token is storing within environment variables and access them via +ENV['TOKEN']+:
    # @example
    #     Genius::Auth.login="#{ENV['TOKEN']}"
    class TokenMissing < StandardError
      attr_reader :msg, :exception_type

      def initialize(msg = "Token is required for this method. Please, add token via `Genius::Auth.login=``token''` method and continue", exception_type = "token_missing")
        super(message)
        @msg = msg
        @exception_type = exception_type
      end
    end

    class << self
      # +Genius::Errors.check_status(token)+          -> true or false
      # @param [String] token The token to access https://api.genius.com.
      # @return [Boolean]
      # This method was made to check token state. Token must be 64-sized string and could be validated only if
      # response status equal 200. More description in {docs}[http://docs.genius.com/] and
      # {api-clients page}[http://genius.com/api-clients] or in
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
      # @param [String] token The token to access https://api.genius.com.
      # @return [Boolean]
      # @example
      #    begin
      #      Genius::Errors.error_handle(token)
      #    rescue Genius::Errors.TokenError => e
      #      puts e.message
      #      puts e.exception_type
      #    end
      # This method is necessary to handle all errors during validation
      def error_handle(token)
        raise TokenError unless token.size == 64
        raise TokenError unless self.check_status(token)
      end
    end
  end
end

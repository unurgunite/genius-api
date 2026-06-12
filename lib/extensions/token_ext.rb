# frozen_string_literal: true

class Object # :nodoc:
  # Returns the provided token or falls back to +Genius::Auth+ stored token.
  #
  # @param [String?] token Token or nil to use stored token.
  # @return [String]
  def token_ext(token)
    token || Genius::Auth.instance_variable_get(:@token)
  end
end

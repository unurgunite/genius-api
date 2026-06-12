# frozen_string_literal: true

class Object # :nodoc:
  # +Object#token_ext+                                -> String
  #
  # Helper method to check if token is correct
  # @param [String] token Token to access https://api.genius.com.
  # @return [String]
  def token_ext(token)
    token || Genius::Auth.instance_variable_get(:@token)
  end
end

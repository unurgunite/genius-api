# frozen_string_literal: true

# +token_ext+                   -> String
# Helper method to check if token is correct
# @param [String] token Token to access https://api.genius.com.
# @return [String]
def token_ext(token)
  token || Genius::Auth.__send__(:token)
end

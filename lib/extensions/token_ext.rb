# frozen_string_literal: true

# Helper method to check if token is correct
def token_ext(token)
  token || Genius::Auth.__send__(:token)
end

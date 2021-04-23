module Genius # :nodoc:
  # +Genius::Search+ module provides methods to work with Genius search database
  module Search
    class << self
      # +Genius::Search.search+     -> value
      # This method is a standard Genius API {method}[https://docs.genius.com/#search-h2] and it is
      # needed to send a request to the server and get information about artists, tracks and everything
      # else that may be inside the response body.
      def search(token = nil, query: nil)
        nil
      end
    end
  end
end

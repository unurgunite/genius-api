# frozen_string_literal: true

# Base module which contains all of other methods/classes/etc.
module Genius
  # +Genius::Api+ is a base module with different constants.
  module Api
    # +Genius::Api::RESOURCE+ constant contains reference to
    # {Genius API}[https://api.genius.com] resource.
    RESOURCE = "https://api.genius.com"
  end
end

require "extensions/extensions"
require_relative "api/errors"
require_relative "api/version"
require_relative "api/authorization"
require_relative "api/account"
require_relative "api/search"
require_relative "api/songs"
require_relative "api/annotations"
require_relative "api/referents"
require_relative "api/artists"
require_relative "api/web_pages"

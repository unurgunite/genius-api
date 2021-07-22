# frozen_string_literal: true

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

module Genius
  module Api
    RESOURCE = "https://api.genius.com"
  end
end

# frozen_string_literal: true

require_relative "lib/genius/api/version"

Gem::Specification.new do |spec|
  spec.name          = "genius-api"
  spec.version       = Genius::Api::VERSION
  spec.authors       = ["unurgunite"]
  spec.email         = ["noreply@example.com"]

  spec.summary       = "Library to work with Genius API"
  spec.description   = "Library to work with Genius API, written in Ruby"
  spec.homepage      = "https://github.com/unurgunite/genius-api"
  spec.license       = "GPL-3.0"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "https://example.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/unurgunite/genius-api"
  spec.metadata["changelog_uri"] = "https://github.com/unurgunite/genius-api/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.post_install_message = "Thanks for installing!\nA Ruby gem for scraping with Genius API🤓"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "httparty", "~> 0.13.7"
  spec.add_development_dependency "nokogiri"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end

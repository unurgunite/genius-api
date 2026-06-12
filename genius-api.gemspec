# frozen_string_literal: true

require_relative 'lib/genius/api/version'

Gem::Specification.new do |spec|
  spec.name          = 'genius-api'
  spec.version       = Genius::Api::VERSION
  spec.authors       = ['unurgunite']

  spec.summary       = 'Library to work with Genius API'
  spec.description   = 'Library to work with Genius API, written in Ruby'
  spec.homepage      = 'https://github.com/unurgunite/genius-api'
  spec.license       = 'GPL-3.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')

  spec.metadata = {
    'allowed_push_host' => 'https://example.com',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/unurgunite/genius-api',
    'changelog_uri' => 'https://github.com/unurgunite/genius-api/blob/master/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.post_install_message = "Thanks for installing!\nA Ruby gem for scraping with Genius API🤓"

  spec.add_dependency 'httparty', '~> 0.21'
  spec.add_dependency 'nokogiri'
  spec.add_development_dependency 'coderay'
  spec.add_development_dependency 'dotenv', '~> 2.7.6'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 1.7'
  spec.add_development_dependency 'yard'
end

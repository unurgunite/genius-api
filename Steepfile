# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature 'sig'
  check 'lib'
  ignore 'lib/extensions/extensions.rb'

  configure_code_diagnostics do |config|
    config[D::Ruby::NoMethod] = :information
  end
end

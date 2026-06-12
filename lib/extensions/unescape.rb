# frozen_string_literal: true

class String # :nodoc:
  # Unescapes JSON-escaped double quotes in a string.
  #
  # @return [String]
  def unescape
    string = gsub(/(?<!\\)(\\")/, '"')
    string.gsub(/(?<!\\)(\\\\")/, '\"')
  end
end

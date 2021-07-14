# frozen_string_literal: true

class String # :nodoc:
  # String#unescape method unescapes input JSON strings
  # @return [String (frozen)]
  def unescape
    string = gsub(/(?<!\\)(\\\")/, "\"")
    string.gsub(/(?<!\\)(\\\\\")/, "\\\"")
  end
end

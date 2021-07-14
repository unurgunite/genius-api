# frozen_string_literal: true

class String # :nodoc:
  def unescape(string)
    string = string.gsub(/(?<!\\)(\\\")/, "\"")
    string = string.gsub(/(?<!\\)(\\\\\")/, "\\\"")
    string
  end
end

# frozen_string_literal: true

require "rspec"
require "extensions/extensions"

describe String do
  describe "#unescape" do
    it "unescapes JSON-escaped double quotes" do
      str = 'test \\"string\\"'
      expect(str.unescape).to eq('test "string"')
    end

    it "handles strings without escaped characters" do
      str = "hello world"
      expect(str.unescape).to eq("hello world")
    end
  end
end

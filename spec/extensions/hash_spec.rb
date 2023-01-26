# frozen_string_literal: true

require "rspec"
require "extensions/extensions"

describe Hash do
  describe "#deep_find" do
    let(:musicians) do
      { "Travis Scott" => { "28" => ["Highest in the Room", "Franchise"] },
        "Adele" => { "19" => ["Day Dreamer", "Best for Last"] },
        "Ed Sheeran" => { "28" => ["Shape of You", "Castle on the Hill"] } }
    end
    let(:new_hash) do
      { "a" => "b", "c" => { "a" => "b" } }
    end

    context "when the option uniq is set to true" do
      it "returns an array of unique values for the given key" do
        expect(musicians.deep_find("19", uniq: true)).to eq(["Day Dreamer", "Best for Last"])
        expect(musicians.deep_find("28",
                                   uniq: true)).to eq([["Highest in the Room", "Franchise"],
                                                       ["Shape of You", "Castle on the Hill"]])
        expect(new_hash.deep_find("a", uniq: true)).to eq("b")
      end
    end

    context "when the option uniq is set to false" do
      it "returns an array of all values for the given key, including duplicates" do
        expect(musicians.deep_find("19", uniq: false)).to eq(["Day Dreamer", "Best for Last"])
        expect(musicians.deep_find("28",
                                   uniq: false)).to eq([["Highest in the Room", "Franchise"],
                                                        ["Shape of You", "Castle on the Hill"]])
        expect(new_hash.deep_find("a", uniq: false)).to eq(%w[b b])
      end
    end

    it "returns the value of the given key if it exists in the top level of the hash" do
      expect(musicians.deep_find("Adele")).to eq({ "19" => ["Day Dreamer", "Best for Last"] })
    end

    it "returns nil if the given key does not exist in the hash" do
      expect(musicians.deep_find("30")).to eq []
    end
  end
end

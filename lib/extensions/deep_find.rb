# frozen_string_literal: true

class Hash # :nodoc:
  # <b>EXPERIMENTAL FEATURE</b>
  # +hash.deep_find(key)+        -> value
  # @param [Object] key A key, which value should be found
  # @param [FalseClass] uniq A flag to make values unique in an array
  # @return [Object]
  # This method is an extension for Hash core class to search for a value of a key in N-nested
  # hash. It provides search for multiple values if key appears more than once. For e.g.:
  #
  #     musicians = { "Travis Scott" => { "28" => ["Highest in the Room", "Franchise"] },
  #                 "Adele" => { "19" => ["Day Dreamer", "Best for Last"] },
  #                 "Ed Sheeran" => { "28" => ["Shape of You", "Castle on the Hill"] } }
  #     musicians.deep_find("19") #=> ["Day Dreamer", "Best for Last"]
  #     musicians.deep_find("Adele") #=> {"19"=>["Day Dreamer", "Best for Last"]}
  #     musicians.deep_find("28") #=> [["Highest in the Room", "Franchise"], ["Shape of You", "Castle on the Hill"]]
  #
  # If values are identical, they will be returned in a single copy. You can disable this
  # feature with special param +uniq+, which is +true+ by default. For e.g.:
  #
  #     h = {"a" => "b", "c" => {"a" => "b"}}
  #     h.deep_find("a") #=> "b", instead ["b", "b"]
  def deep_find(key, uniq: true)
    result = []
    result << self[key]
    each_value do |hash_value|
      values = hash_value.is_a?(Array) ? hash_value : [hash_value]
      values.each do |value|
        result << value.deep_find(key) if value.is_a? Hash
      end
    end
    result = result.compact.delete_if do |i|
      i.is_a?(Array) && i.empty?
    end
    uniq ? result.uniq! : result
    result.size == 1 ? result.first : result
  end
end

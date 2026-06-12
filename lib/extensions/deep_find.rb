# frozen_string_literal: true

class Hash # :nodoc:
  # +Hash#deep_find+                                  -> value
  #
  # @param [Object] key A key, which value should be found
  # @param [FalseClass] uniq A flag to make values unique in an array
  # @return [Object] output depends on key value
  # This method is an extension for Hash core class to search for a value of a key in N-nested
  # hash. It provides search for multiple values if key appears more than once. For e.g.:
  #
  # @example
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
  # @example
  #     h = {"a" => "b", "c" => {"a" => "b"}}
  #     h.deep_find("a") #=> "b", instead ["b", "b"]
  # @todo change uniq true to uniq false
  def deep_find(key, uniq: true)
    result = collect_values(key)
    result.compact!
    result.delete_if { |i| i.is_a?(Array) && i.empty? }
    result.uniq! if uniq
    return nil if result.empty?

    result.size == 1 ? result.first : result
  end

  private

  def collect_values(key)
    result = [self[key]]
    each_value do |value|
      values = value.is_a?(Array) ? value : [value]
      values.each do |v|
        result << v.deep_find(key) if v.is_a?(Hash)
      end
    end
    result
  end
end

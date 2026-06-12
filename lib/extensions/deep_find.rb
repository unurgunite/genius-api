# frozen_string_literal: true

class Hash # :nodoc:
  # Searches for a key in nested hashes and arrays. Returns matching values or +nil+.
  #
  # @param [Object] key Key to search for.
  # @param [Boolean] uniq If +true+, deduplicates results.
  # @return [nil, Object]
  def deep_find(key, uniq: true)
    result = collect_values(key)
    result.compact!
    result.delete_if { |i| i.is_a?(Array) && i.empty? }
    result.uniq! if uniq
    return nil if result.empty?

    result.size == 1 ? result.first : result
  end

  private

  # Recursively collects values for a key from nested hashes.
  #
  # @private
  # @param [Object] key Key to search for.
  # @return [Array]
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

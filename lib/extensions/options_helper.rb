# frozen_string_literal: false

class Object # :nodoc:
  # Builds a query string from allowed options keys.
  #
  # @param [Hash] options Options hash with symbol keys.
  # @param [Array] arry Allowed keys to include in the query string.
  # @return [String]
  def options_helper(options, arry)
    params = ''
    opt = arry
    options.each do |k, v|
      params.insert(params.length, "&#{k}=#{v}") if opt.include? k
    end
    params
  end
end

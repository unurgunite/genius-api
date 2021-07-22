# frozen_string_literal: true

# @param [Hash] options Hash with params for response.
# @param [Array] arry Array of possible params for response.
# @return [String]
def options_helper(options, arry)
  params = ""
  opt = arry
  options.each_key do |k, v|
    params.insert(params.length, "&#{k}=#{v}") if opt.include? k
  end
  params
end

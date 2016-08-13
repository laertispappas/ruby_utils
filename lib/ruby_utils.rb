require "ruby_utils/version"
require 'ruby_utils/param'
require 'ruby_utils/core_ext/hash'

module Ruby
  module Utils

    module_function
    def Param(original = {})
      Param.new(original || {})
    end
  end
end

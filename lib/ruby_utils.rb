require "ruby_utils/version"
require 'ruby_utils/param'
require 'ruby_utils/core_ext/hash'
require 'ruby_utils/option'
require 'ruby_utils/list'


None = Ruby::Utils::None.instance

def Some(value)
  Ruby::Utils::Some.new(value)
end

module Ruby
  module Utils
    module_function
    def Param(original = {})
      Param.new(original || {})
    end

    def flatten(array)
      unless array.respond_to?(:each)
        raise "Utils::Array#flatten: An array should be passed!"
      end
      result = []

      while(element = array.shift) do
        if element.respond_to?(:each)
          result += self.flatten(element)
        else
          result << element
        end
      end

      result
    end

  end
end

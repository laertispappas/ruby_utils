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
  end
end

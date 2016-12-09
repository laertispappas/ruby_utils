module Ruby::Utils
  class Param
    # TODO include Enumerable

    def initialize(hash = {})
      @original_hash = hash

      define_methods(@original_hash)
    end

    def define_methods(h)
      h.each do |k, v|
        h.define_singleton_method(k) do
          v
        end

        define_methods(v) if v.is_a?(Hash)
      end
    end

    def respond_to?(name)
      if @original_hash.respond_to?(name)
        true
      else
        super
      end
    end

    def method_missing(name, *args, &block)
      if @original_hash.respond_to?(name)
        @original_hash.send(name)
      else
        super
      end
    end

    # Returns the value of the hash given a delimited key
    # If not key is found an error is raised
    #
    # @param[String] key A delimited string key to find the value of the hash
    #
    # @return [Object, Exception] Exception if no key is found or else the value
    #
    # => params.get(".poll.user.profile.email")
    #
    def get(key)
      methods = key.scan(/[\w'-]+/)
      _get(methods, self)
    end

    def _get(methods, obj)
      current = methods.shift
      res = obj.send(current)

      return res if methods.empty?
      _get(methods, res)
    end
    private :_get

    # Get a value from hash. If it's not set, return default value. If default value 
    # is not provided, return nil. Never throw exception.
    #
    # ex:
    # params.getOrElse(":user:location:address", "Street address") # => "Betonimiehenkuja 5"
    # params.getOrElse(":user:location:zipcode", "00000")          # => "00000"
    # params.getOrElse(":user:location:zipcode", params.getOrElse(":user:location:address", "N/A")) # => "Betonimiehenkuja 5"
    #
    # TODO Add more args for fallbacks:
    #
    # getOrElse(locator, [fallback_locator_1, ... , fallback_locator_n], default)]
    # params.getOrElse(":user:location:zipcode", ":user:location:address", "N/A") # => "Betonimiehenkuja 5"
    # params.getOrElse(":user:location:zipcode", ":user:location:state", "N/A") # => "N/A"
    # params.getOrElse(":user:location:zipcode", ":user:location:state", ":user:location:country", "N/A") # => "Finland"
    #
    def getOrElse(locator, default=nil)
      get(locator)
    rescue NoMethodError
      default
    end

    # Get a value from hash and map the value with block.
    # If value is not set, do nothing.
    #
    # =>  mappedParams = params.map(":user:location:city", &:upcase)
    # =>  mappedParams.get(:city) # => "HELSINKI"
    def map(key, &block)
      result = getOrElse(key)
      block.call(result) if result
    end

    def map_keys(h, &block)
      Hash[h.map { |(k, v)| [block.call(k), v] }]
    end

    def map_values(h, &block)
      h.inject({}) do |memo, (k, v)|
        memo[k] = block.call(v)
        memo
      end
    end

    # Select a subset of the hash h using given set of keys.
    # Only include keys that are present in h.
    # Usage:
    #   sub({first: "First", last: "Last", age: 55}, :first, :age, :sex)
    #   => {first: "First", age: 55}
    def sub(h, *keys)
      keys.reduce({}) do |sub_hash, k|
        sub_hash[k] = h[k] if h.has_key?(k)
        sub_hash
      end
    end

    # Select values by given keys from array of hash
    # Usage:
    # pluck([{name: "John", age: 15}, {name: "Joe"}], :name, :age) => ["John", "Joe", 15]
    def pluck(array_of_hashes, *keys)
      array_of_hashes.map { |h|
        keys.map { |key| h[key] }
      }.flatten.compact
    end

    # Return true if given subset of fields in both hashes are equal
    # Usage:
    #   suq_eq({a: 1, b: 2, c: 3}, {a: 1, b: 2, c: 4}, :a, :b) => true
    def sub_eq(a, b, *keys)
      a.slice(*keys) == b.slice(*keys)
    end

    # deep_contains({a: 1}, {a: 1, b: 2}) => true
    # deep_contains({a: 2}, {a: 1, b: 2}) => false
    # deep_contains({a: 1, b: 1}, {a: 1, b: 2}) => false
    # deep_contains({a: 1, b: 2}, {a: 1, b: 2}) => true
    def deep_contains(needle, haystack)
      needle.all? do |key, val|
        haystack_val = haystack[key]
        if val.is_a?(Hash) && haystack_val.is_a?(Hash)
          deep_contains(val, haystack_val)
        else
          val == haystack_val
        end
      end
    end

    # wrap_if_present(:wrap, {a: 1}} -> {wrap: {a: 1}}
    # wrap_if_present(:wrap, {}} -> {}
    # wrap_if_present(:wrap, nil) -> {}
    def wrap_if_present(key, value)
      Maybe(value).map { |v|
        Hash[key, v]
      }.or_else({})
    end

    # { a: b: 1 } -> { :"a.b" => 1 }"}
    def flatten(h)
      # use helper lambda 
      acc = ->(prefix, hash) {
        hash.inject({}) { |memo, (k, v)|
          key_s = k.to_s
          if !k.is_a?(Symbol) || key_s.include?(".")
            raise ArgumentError.new("Key must be a Symbol and must not contain dot (.). Was: '#{k.to_s}', (#{k.class.name})")
          end
          prefixed_key = prefix.nil? ? k : [prefix.to_s, key_s].join(".")
          if v.is_a? Hash
            memo.merge(acc.call(prefixed_key, v))
          else
            memo.merge(prefixed_key.to_sym => v)
          end
        }
      }

      acc.call(nil, h)
    end

    # p = Person.new({name: "Foo", email: "foo@example.com"})
    # object_to_hash(p) => {name: "Foo" , email: "foo@example.com"}
    def object_to_hash(object)
      object.instance_variables.inject({}) do |hash, var|
        hash[var.to_s.delete("@")] = object.instance_variable_get(var)
        hash
      end
    end

    # Return true if the value is set.
    #
    # has_address = params.defined?(":user:location:address")
    # has_address # => true
    #
    def defined?(locator)
      !getOrElse(locator).nil?
    end

    # Return true if all of the values are set.
    #
    # can_show_fullname = params.all?(":user:name:first", ":user:name:last")
    #
    def all?(*locators)
      locators.all? { |locator| getOrElse(locator) }
    end

    # Run a given block only if value is defined.
    #
    # params.with(":user:location:address") { |address| puts "Address: #{address}"} } # => "Address: Betonimiehenkuja 5"
    # params.with(":user:location:city") { |city| puts "City: #{}"}
    #
    def with(key, &block)
      result = getOrElse(key)
      yield(result) if result
    end

    def to_h
      @original_hash
    end
    alias_method :to_hash, :to_h
    alias_method :as_hash, :to_h
  end # End Param
end


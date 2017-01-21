module Ruby
  module Utils

    class Option
      # @abstract
      def empty?
        raise NotImplementedError
      end

      def defined?
        !empty?
      end

      # @abstract
      def get
        raise NotImplemtedError
      end

      def get_or_else(default)
        return default if empty?
        self.get
      end

      def map(f = nil)
        return None.instance if empty?

        if block_given?
          result = yield(self.get)
        else
          Some(f.call(self.get))
        end
      end

      def flat_map(f = nil)
        return None.instance if empty?

        if block_given?
          result = yield(self.get)
        else
          f.call(self.get)
        end
      end

      def filter(p = nil)
        if block_given?
          yield(self.get) ? self : None.instance
        else
          (empty? || p[self.get]) ? self : None.instance
        end
      end

      def for_each(f = nil)
        if block_given? && !empty?
          return yield(self.get)
        end
        if !empty?
          f.call(self.get)
        end
      end

      def or_else(other)
        empty? ? other : self
      end

      def to_a
        empty? ? Array.new : Array(self.get)
      end

      def match(&block)
        instance_eval(&block)
      end

      # @abstract
      def on(option)
        raise NotImplementedError
      end
    end


    class Some < Option
      def initialize(value)
        @value = value
      end

      def method_missing(name, *args, &block)
       @_caller_method ||= caller_locations[2].to_s.scan(/\`(.*)'/).flatten.first

        unless @_caller_method == 'match'
          super
        end

        self.get unless empty?
      end

      def empty?
        false
      end

      def get
        @value
      end

      def on(option)
        if option.keys.first.is_a? Some
          @__to_yield_value ||= option[option.keys.first]
        end
        @__to_yield_value
      end

      def ==(other)
        other.get == self.get
      end
    end


    class None < Option
      class RescueAll
        def method_missing(name, *args, &block)
        end
      end

      require 'singleton'
      include Singleton

      class NoSuchElementError < StandardError; end

      def empty?
        true
      end

      def get
        raise NoSuchElementError.new("None.get")
      end

      def method_missing(name, *args, &block)
       @_caller_method ||= caller_locations[2].to_s.scan(/\`(.*)'/).flatten.first

        unless @_caller_method == 'match'
          super
        end

        RescueAll.new
      end

      def on(option)
        option[self] if option.keys.first.is_a?(None)
      end
    end
  end

end

module Ruby
  module Utils
    class List
      attr_reader :head, :tail

      def self.[](*elements)
        if elements.any?
          Cons.new(elements.shift, self[*elements])
        else
          Nil.new
        end
      end

      # @abstract
      def kase(some)
        raise NotImplementedError
      end
     def match(&block)
        instance_eval(&block)
      end
    end

    class Nil < List
      class RescueAll
        def method_missing(name, *args, &block)
        end
      end

      def empty?
        true
      end

      def head
        raise 'Nil.head'
      end

      def tail
        raise 'Nil.tail'
      end

      def kase(list)
        if list.keys.first == Nil
          @_case_result = list.values.first
        end
        @_case_result
      end

      def method_missing(name, *args, &block)
       @_caller_method ||= caller_locations[2].to_s.scan(/\`(.*)'/).flatten.first

        unless @_caller_method == 'match'
          super
        end

        RescueAll.new
      end
    end

    class Cons < List
      def initialize(head, tail)
        @head = head
        @tail = tail
      end

      def kase(list)
        unless list.keys.first == Nil
          @_kase_result = list.values.first
        end
        @_kase_result
      end


      def method_missing(name, *args, &block)
        @calls_count ||= 0
        @calls_count += 1

        @_caller_method ||= caller_locations[2].to_s.scan(/\`(.*)'/).flatten.first

        unless @_caller_method == 'match'
          super
        end

        if @calls_count == 1
          define_singleton_method(name) do
            self.head
          end
        elsif @calls_count == 2
          define_singleton_method(name) do
            self.tail
          end
        else
          super
        end
      end

      def empty?
        false
      end
    end

  end
end

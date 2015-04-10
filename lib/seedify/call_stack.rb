module Seedify
  class CallStack
    class << self
      def call(proc)
        stack.push(proc)
        proc.call
        stack.pop
      end

      def last
        stack.last
      end

      private

      def stack
        Thread.current[:seedify_call_stack] ||= []
      end
    end
  end
end

module Seedify
  class CallStack
    class << self
      def call(proc)
        stack.push(proc)

        if proc.class.respond_to?(:get_callbacks)
          Seedify::Callbacks.with_callbacks(proc) do
            proc.call
          end
        else
          proc.call
        end

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

module Seedify
  module Callbacks
    TYPES = %w{before_all}

    def self.with_callbacks(proc)
      @finished_before_all ||= []

      proc.class.get_callbacks(:before_all).each do |callback|
        unless @finished_before_all.include?(callback)
          @finished_before_all << callback

          proc.send(callback)
        end
      end

      yield
    end

    def inherited(subclass)
      super

      TYPES.each do |type|
        get_callbacks(type).each do |callback|
          subclass.send(type, callback)
        end
      end
    end

    TYPES.each do |type|
      define_method type do |callback|
        @callbacks ||= {}
        @callbacks[type] ||= []
        @callbacks[type] << callback
      end
    end

    def get_callbacks(type)
      Array((@callbacks || {})[type.to_s])
    end
  end
end

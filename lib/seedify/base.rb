module Seedify
  class Base
    extend Seedify::ParamReader

    attr_reader :params

    param_reader :log, type: :boolean, default: true
    param_reader :task, type: :boolean, default: false

    def self.call(overrides = {})
      seed = self.new(params(overrides))

      Seedify::CallStack.call(seed)
    end

    def self.params(overrides)
      stacked_params = (Seedify::CallStack.last.try(:params) || {}).merge(overrides)
      defined_params = get_param_readers.map do |param_name, options|
        [param_name, Seedify::ParamValue.get(param_name, options)]
      end.to_h

      defined_params.merge(stacked_params)
    end

    def initialize(params)
      @params = params
      @logger = Seedify::Logger.new(self)
    end

    def log(message, &block)
      @logger.line(message, &block)
    end

    def log_each(array, message, &block)
      @logger.each(array, message, &block)
    end

    def log_times(count, message, &block)
      @logger.times(count, message, &block)
    end
  end
end

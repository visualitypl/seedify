module Seedify
  module ParamReader
    def inherited(subclass)
      super

      get_param_readers.each do |param_name, options|
        subclass.param_reader param_name, options
      end
    end

    def param_reader(param_name, options = {})
      param_name = param_name.to_sym
      getter_name = options[:type] == :boolean ? "#{param_name}?" : param_name

      @params ||= {}
      @params[param_name] = options

      define_method(getter_name) { params[param_name] }
    end

    def get_param_readers
      @params || {}
    end
  end
end

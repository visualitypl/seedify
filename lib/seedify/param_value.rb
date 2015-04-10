module Seedify
  class ParamValue
    class << self
      def get(param_name, options)
        value = get_env_value(param_name) || get_default_value(options[:default])
        value = get_type_casted_value(value, options[:type])

        value
      end

      private

      def get_env_value(param_name)
        ENV[param_name.to_s]
      end

      def get_default_value(default)
        if default.respond_to?(:call)
          default.call
        else
          default
        end
      end

      def get_type_casted_value(value, type)
        case type.to_s
        when 'boolean'
          value.to_s.in?(%{1 true})
        when 'integer'
          (value || 0).to_i
        else
          value
        end
      end
    end
  end
end

module Foreigner
  class Adapter
    class_attribute :registered
    self.registered = {}

    class << self
      def register(adapter_name, file_name)
        registered[adapter_name] = file_name
      end

      def load!
        if registered.key?(configured_name)
          require registered[configured_name]
        else
          p "Database adapter #{configured_name} not supported. Use:\n" +
            "Foreigner::Adapter.register '#{configured_name}', 'path/to/adapter'"
        end
      end

      def configured_name
        @configured_name ||= ActiveRecord::Base.connection_pool.spec.config[:adapter]
      end

      def safe_include(adapter_class_name, foreigner_module)
        ActiveRecord::ConnectionAdapters.const_get(adapter_class_name).class_eval do
          unless ancestors.include? foreigner_module
            include foreigner_module
          end
        end
      rescue
      end
    end
  end
end

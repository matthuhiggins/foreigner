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
        end
      end

      def configured_name
        ActiveRecord::Base.connection_pool.spec.config[:adapter]
      end
    end
  end
end
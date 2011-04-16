module Foreigner
  module Migration
    module CommandRecorder
      def add_foreign_key(*args)
        record(:add_foreign_key, args)
      end

      def remove_foreign_key(*args)
        record(:remove_foreign_key, args)
      end

      def invert_add_foreign_key(*args)
        [:remove_foreign_key, args]
      end
      
      def invert_remove_foreign_key(*args)
        [:add_foreign_key, args]
      end
    end
  end
end
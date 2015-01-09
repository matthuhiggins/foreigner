module Foreigner
  module Helper
    def self.active_record_version
      if ::ActiveRecord.respond_to? :version
        ActiveRecord.version.to_s
      elsif ::ActiveRecord::VERSION
        ::ActiveRecord::VERSION
      else
        raise "Unknown ActiveRecord Version API"
      end
    end
  end
end

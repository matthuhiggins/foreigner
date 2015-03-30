module Foreigner
  module Helper
    def self.active_record_version
      if ::ActiveRecord.respond_to? :version
        ActiveRecord.version
      elsif ::ActiveRecord::VERSION::STRING
        Gem::Version.new(::ActiveRecord::VERSION::STRING)
      else
        raise "Unknown ActiveRecord Version API"
      end
    end
  end
end

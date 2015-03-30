module Foreigner
  module Helper
    def self.active_record_version
      if ::ActiveRecord.respond_to? :version
        ActiveRecord.version
      elsif ::ActiveRecord::VERSION
        Gem::Version.new(::ActiveRecord::VERSION)
      else
        raise "Unknown ActiveRecord Version API"
      end
    end
  end
end

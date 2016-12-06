module Foreigner
  def self.standalone_migrations_autoload_supported?
    StandaloneMigrations.respond_to? :on_load
  end

  def self.load_standalone_migrations_autoloader
    if standalone_migrations_autoload_supported?
      StandaloneMigrations.on_load do
        Foreigner.load
      end
    end
  end
end

Foreigner.load_standalone_migrations_autoloader

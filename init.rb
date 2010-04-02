require 'foreigner'

Foreigner.register 'mysql', 'foreigner/connection_adapters/mysql_adapter'
Foreigner.register 'postgresql', 'foreigner/connection_adapters/postgresql_adapter'

config.after_initialize do
  Foreigner.on_load do
    Foreigner.load_adapter!
  end
end

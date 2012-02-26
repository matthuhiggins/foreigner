module Foreigner
  class Railtie < Rails::Railtie
    initializer 'foreigner.load_adapter' do
      Foreigner.load_adapter
    end
  end
end

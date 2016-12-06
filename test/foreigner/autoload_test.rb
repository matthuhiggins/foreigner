class AutoloadTest < ActiveSupport::TestCase
  test "autoloads for standalone migrations" do
    # this should not exist
    assert_raise NameError do
      StandaloneMigrations
    end

    # and if it were to exist
    require 'standalone_migrations'
    StandaloneMigrations.expects(:on_load)
    load 'foreigner.rb'

    assert_equal(Foreigner.standalone_migrations_autoload_supported?, true)
  end

  test "autoloads for rails" do
    # this should not exist
    assert_raise NameError do
      Foreigner::Railtie
    end

    require 'rails'
    load 'foreigner.rb'

    assert_not_nil(Foreigner::Railtie)
  end
end
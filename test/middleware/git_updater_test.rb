require 'test_helper'

context "Simpleton::Middleware::GitUpdater.call" do
  asserts "that without arguments it" do
    Simpleton::Middleware::GitUpdater.call
  end.raises(Simpleton::Error, /requires.*:commit and :directory/)

  asserts "that with a hash which does not include :directory it" do
    Simpleton::Middleware::GitUpdater.call(:commit => "abc123")
  end.raises(Simpleton::Error, /requires.*:commit and :directory/)

  asserts "that with a hash which does not include :commit it" do
    Simpleton::Middleware::GitUpdater.call(:directory => "foo")
  end.raises(Simpleton::Error, /requires.*:commit and :directory/)

  configuration = { :commit => "abc123", :directory => "/data/awesome_app" }
  context "with #{configuration.inspect}" do
    setup { Simpleton::Middleware::GitUpdater.call(configuration) }

    asserts_topic("that its return value").equals("cd /data/awesome_app && git fetch && git reset --hard abc123")
  end
end

require 'test_helper'

context "Simpleton::Middleware::PassengerRestarter.call" do
  asserts "that without arguments it" do
    Simpleton::Middleware::PassengerRestarter.call
  end.raises(Simpleton::Error, /requires.*:directory/)

  asserts "that with a hash which does not include :directory it" do
    Simpleton::Middleware::PassengerRestarter.call(:foo => "bar")
  end.raises(Simpleton::Error, /requires.*:directory/)

  configuration = { :directory => "/data/awesome_app" }
  context "with #{configuration.inspect}" do
    setup { Simpleton::Middleware::PassengerRestarter.call(configuration) }

    asserts_topic("that its return value").equals("touch /data/awesome_app/tmp/restart.txt")
  end
end

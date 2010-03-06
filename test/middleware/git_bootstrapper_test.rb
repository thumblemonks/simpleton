require 'test_helper'

context "Simpleton::Middleware::GitBootstrapper.call" do
  asserts "that without arguments it" do
    Simpleton::Middleware::GitBootstrapper.call
  end.raises(Simpleton::Error, /requires.*:directory/)

  asserts "that with a hash which does not include :directory it" do
    Simpleton::Middleware::GitBootstrapper.call(:repository => "foo")
  end.raises(Simpleton::Error, /requires.*:directory and :repository/)

  asserts "that with a hash which does not include :repository it" do
    Simpleton::Middleware::GitBootstrapper.call(:directory => "foo")
  end.raises(Simpleton::Error, /requires.*:directory and :repository/)

  configuration = {:directory => "/data/awesome_app", :repository => "git://example.com/awesome_app"}
  context "with #{configuration.inspect}" do
    setup { Simpleton::Middleware::GitBootstrapper.call(configuration) }

    asserts_topic("that its return value").equals("git clone git://example.com/awesome_app /data/awesome_app")
  end
end

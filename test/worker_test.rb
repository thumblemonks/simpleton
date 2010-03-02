require 'test_helper'
require 'simpleton/worker'

context "A Simpleton::Worker" do
  host = "foo"
  middleware_chain = [ Proc.new {"echo 123"} ]

  context "instantiated with (#{host}, #{middleware_chain.inspect})" do
    setup { Simpleton::Worker.new(host, middleware_chain) }

    asserts(:host).equals(host)
    asserts(:middleware_chain).equals(middleware_chain)
  end
end

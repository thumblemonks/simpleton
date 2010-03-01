require 'test_helper'
require 'simpleton/worker'
require 'simpleton/command_runners/system'

context "A Simpleton::Worker" do
  host = "foo"
  middleware_chain = [Proc.new {}]

  context "instantiated with 3 arguments" do
    mock_command_runner = Object.new
    setup { Simpleton::Worker.new(host, middleware_chain, mock_command_runner) }

    asserts(:host).equals(host)
    asserts(:middleware_chain).equals(middleware_chain)
    asserts(:command_runner).equals(mock_command_runner)
  end

  context "instantiated with 2 arguments" do
    setup { Simpleton::Worker.new(host, middleware_chain) }

    asserts(:host).equals(host)
    asserts(:middleware_chain).equals(middleware_chain)
    asserts(:command_runner).kind_of(Simpleton::CommandRunners::System)
  end
end

require 'test_helper'

context "Simpleton::Worker.new" do
  host = "foo"
  middleware_chain = [ Proc.new {"echo 123"} ]

  context "with arguments (#{host}, #{middleware_chain.inspect})" do
    setup { Simpleton::Worker.new(host, middleware_chain) }

    asserts(:host).equals(host)
    asserts(:middleware_chain).equals(middleware_chain)
    asserts(:command_runner).equals(Simpleton::CommandRunners::System)
  end

  command_runner = Object.new
  def command_runner.run; end

  context "with arguments (#{host}, #{middleware_chain.inspect}, #{command_runner})" do
    setup { Simpleton::Worker.new(host, middleware_chain, command_runner) }

    asserts(:host).equals(host)
    asserts(:middleware_chain).equals(middleware_chain)
    asserts(:command_runner).equals(command_runner)
  end
end

context "Simpleton::Worker#run" do
  setup { @worker = Simpleton::Worker.new("app1", [Proc.new {"a"}, Proc.new {"b"}]) }

  context "when all commands are successful" do
    should "run the command_runner with the host and result of middleware.call for each middleware in the chain" do
      topic.middleware_chain.each do |middleware|
        mock(topic.command_runner).run(topic.host, middleware.call) {true}
      end

      topic.run
    end
  end

  context "when not all commands are successful" do
    should "only run commands up to and including the first failed command" do
      mock(topic.command_runner).run(topic.host, topic.middleware_chain.first.call) {false}
      mock(topic.command_runner).run(topic.host, topic.middleware_chain.last.call).never

      @worker.run
      true
    end

    should "return false" do
      stub(topic.command_runner).run(topic.host, topic.middleware_chain.first.call) {false}

      false == @worker.run
    end
  end
end

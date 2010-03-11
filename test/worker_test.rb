require 'test_helper'

context "Simpleton::Worker.new" do
  host = "foo"
  middleware_chain = [ Proc.new {"echo 123"} ]

  context "with arguments (#{host}, #{middleware_chain.inspect})" do
    setup { Simpleton::Worker.new(host, middleware_chain, Simpleton::CommandRunners::System) }

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
  setup { Simpleton::Worker.new("app1", [Proc.new {"a"}, Proc.new {"b"}], Simpleton::CommandRunners::System) }

  should "call each middleware with Simpleton::Configuration" do
    topic.middleware_chain.each do |middleware|
      mock(middleware).call(Simpleton::Configuration) {""}
    end

    topic.run
  end

  should "supply its command runner with the Worker's host" do
    mock(topic.command_runner).run(topic.host, anything).times(2) {true}

    topic.run
  end

  context "when there are command failures" do
    should "stop running commands after the first failure" do
      mock(topic.command_runner).run(anything, topic.middleware_chain.first.call) {false}
      mock(topic.command_runner).run(anything, topic.middleware_chain.last.call).never

      topic.run
      true
    end

    asserts "that its return value" do
      stub(topic.command_runner).run(anything, topic.middleware_chain.first.call) {false}

      topic.run
    end.equals(false)
  end

  context "when some Middleware raise Simpleton::Error" do
    should "not run any commands" do
      stub(topic.middleware_chain.last).call {raise Simpleton::Error}
      mock(topic.command_runner).run.never

      begin
        topic.run
      rescue Simpleton::Error
        true
      end
    end
  end

  context "without any command failures or Middleware exceptions" do
    should "run the commands from every middleware in its chain" do
      topic.middleware_chain.each do |middleware|
        mock(topic.command_runner).run(anything, middleware.call) {true}
      end

      topic.run
    end
  end
end

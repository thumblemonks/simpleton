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

  should "run every middleware through the command runner when there are no failures" do
    topic.middleware_chain.each do |middleware|
      mock(topic.command_runner).run(anything, middleware.call) {true}
    end

    topic.run
  end

  should "stop running middleware through the command runner after the first failure" do
    mock(topic.command_runner).run(anything, topic.middleware_chain.first.call) {false}
    mock(topic.command_runner).run(anything, topic.middleware_chain.last.call).never

    topic.run
    true
  end

  asserts "that its return value when running a middleware through the command runner fails" do
    stub(topic.command_runner).run(anything, topic.middleware_chain.first.call) {false}

    topic.run
  end.equals(false)

  should "call each middleware with Simpleton::Configuration" do
    topic.middleware_chain.each do |middleware|
      mock(middleware).call(Simpleton::Configuration) {""}
    end

    topic.run
  end

  should "run its command runner with the Worker's host" do
    mock(topic.command_runner).run(topic.host, anything).times(2) {true}

    topic.run
  end
end

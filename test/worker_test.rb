require 'test_helper'

context "Simpleton::Worker.new" do
  location = "user@host"
  middleware_chain = [ Proc.new {"echo 123"} ]
  command_runner = Simpleton::CommandRunner

  context "with arguments (#{location}, #{middleware_chain.inspect}, #{command_runner})" do
    setup { Simpleton::Worker.new(location, middleware_chain, command_runner) }

    asserts(:location).equals(location)
    asserts(:middleware_chain).equals(middleware_chain)
    asserts(:command_runner).equals(command_runner)
  end
end

context "Simpleton::Worker#run" do
  setup { Simpleton::Worker.new("app1", [Proc.new {"a"}, Proc.new {"b"}], Object.new) }

  should "call each middleware with Simpleton::Configuration" do
    stub(topic.command_runner).run {true}
    stub(Process).exit {true}

    topic.middleware_chain.each do |middleware|
      mock(middleware).call(Simpleton::Configuration) {""}
    end

    topic.run
  end

  should "supply its command runner with the Worker's location" do
    stub(Process).exit {true}

    mock(topic.command_runner).run(topic.location, anything).times(2) {true}

    topic.run
  end

  context "when there are command failures" do
    should "stop running commands after the first failure" do
      stub(Process).exit {true}

      mock(topic.command_runner).run(anything, topic.middleware_chain.first.call) {false}
      mock(topic.command_runner).run(anything, topic.middleware_chain.last.call).never

      topic.run
      true
    end

    should "call Process.exit(1)" do
      stub(topic.command_runner).run(anything, topic.middleware_chain.first.call) {false}

      mock(Process).exit(1)

      topic.run
      true
    end
  end

  context "when some Middleware raise Simpleton::Error" do
    should "not run any commands" do
      stub(topic.middleware_chain.last).call {raise Simpleton::Error}
      stub(Process).exit {true}

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
      stub(Process).exit {true}

      topic.middleware_chain.each do |middleware|
        mock(topic.command_runner).run(anything, middleware.call) {true}
      end

      topic.run
    end

    should "call Process.exit(0)" do
      topic.middleware_chain.each do |middleware|
        stub(topic.command_runner).run(anything, middleware.call) {true}
      end

      mock(Process).exit(0) {true}

      topic.run
    end
  end
end

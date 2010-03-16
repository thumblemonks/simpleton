require 'test_helper'

context "Simpleton" do
  setup { Simpleton }
  asserts_topic.responds_to :configure
  asserts_topic.responds_to :use

  asserts("that Simpleton::Configuration") { Simpleton::Configuration }.kind_of(Hash)
  asserts("that Simpleton::MiddlewareChains") { Simpleton::MiddlewareChains }.kind_of(Hash)

  asserts("that Simpleton::CommandRunners is autoloaded") { Simpleton::CommandRunners }
  asserts("that Simpleton::Worker is autoloaded") { Simpleton::Worker }
end

context "Simpleton.configure" do
  context "with a block with single argument" do
    desired_configuration = { :foo => "bar", :hello => "world" }
    setup do
      Simpleton.configure { |config| config.merge!(desired_configuration) }
    end

    should("set Simpleton::Configuration appropriately") do
      Simpleton::Configuration
    end.equals(desired_configuration)

    teardown { Simpleton::Configuration.clear }
  end
end

[nil, []].each do |invalid_hosts_value|
  context "When the hosts are #{invalid_hosts_value.inspect}," do
    setup do
      Simpleton.configure { |config| config[:hosts] = invalid_hosts_value }
    end

    context "Simpleton.use" do
      asserts("that it") { Simpleton.use(Class.new) }.raises(Simpleton::Error, /would not apply/)
    end

    teardown do
      Simpleton::Configuration.clear
      Simpleton::MiddlewareChains.clear
    end
  end
end

context %Q[When the hosts are ["app1", "app2", "app3"],] do
  setup do
    Simpleton.configure { |config| config[:hosts] = ["app1", "app2", "app3"] }
  end

  context "Simpleton.use(middleware)" do
    setup do
      @middleware = Proc.new {""}
      Simpleton.use @middleware
    end

    should "add the middleware to each host's chain" do
      Simpleton::Configuration[:hosts].all? do |host|
        Simpleton::MiddlewareChains[host].detect { |middleware| middleware == @middleware }
      end
    end

    should "add the middleware in each host's chain only once" do
      Simpleton::Configuration[:hosts].all? do |host|
        1 == Simpleton::MiddlewareChains[host].select { |middleware| middleware == @middleware }.size
      end
    end

    teardown { Simpleton::MiddlewareChains.clear }
  end

  context %Q[Simpleton.use(middleware, :only => ["app2"])] do
    setup do
      @middleware = Class.new
      @applicable_hosts = ["app2"]
      Simpleton.use @middleware, :only => @applicable_hosts
    end

    should "add the middleware to the specified hosts" do
      @applicable_hosts.all? do |host|
        Simpleton::MiddlewareChains[host].detect { |middleware| middleware == @middleware }
      end
    end

    should "not the middleware to any hosts that were not specified" do
      non_applicable_hosts = Simpleton::Configuration[:hosts] - @applicable_hosts
      non_applicable_hosts.all? do |host|
        !Array(Simpleton::MiddlewareChains[host]).detect { |middleware| middleware == @middleware }
      end
    end

    should "add the middleware in each host's chain only once" do
      @applicable_hosts.all? do |host|
        1 == Simpleton::MiddlewareChains[host].select { |middleware| middleware == @middleware }.size
      end
    end
  end

  context %Q[Simpleton.use(middleware, :only => ["not_configured"])] do
    asserts("that it") do
      Simpleton.use(@middleware, :only => ["not_configured"])
    end.raises(Simpleton::Error, /some.*are not configured/i)
  end

  teardown do
    Simpleton::Configuration.clear
    Simpleton::MiddlewareChains.clear
  end
end

context "Simpleton.run" do
  setup do
    Simpleton.configure { |config| config[:hosts] = ["app1", "app2", "app3"] }
    Simpleton.use Proc.new {""}
  end

  should "fork a new process for each configured host" do
    mock(Simpleton).fork.times(Simpleton::Configuration[:hosts].length) { true }

    Simpleton.run
  end

  should "wait for all its children and clear MiddlewareChains after they return" do
    stub(Simpleton).fork {true}
    mock.proxy(Process).waitall

    Simpleton.run
    {} == Simpleton::MiddlewareChains
  end

  should "run each Worker constructed in the child process" do
    stub(Simpleton).fork { |block| block.call }
    Simpleton::MiddlewareChains.each do |host, chain|
      stub(Simpleton::Worker).new { mock!.run }
    end

    Simpleton.run
  end

  should "construct a new Worker in child process with the appropriate host" do
    stub(Simpleton).fork { |block| block.call }
    Simpleton::MiddlewareChains.each do |host, chain|
      mock.proxy(Simpleton::Worker).new(host, anything, anything)
    end

    Simpleton.run
  end

  should "construct a new Worker in child process with the appropriate chain" do
    stub(Simpleton).fork { |block| block.call }
    Simpleton::MiddlewareChains.each do |host, chain|
      mock.proxy(Simpleton::Worker).new(anything, chain, anything)
    end

    Simpleton.run
  end

  should "return true when all its children exit successfully" do
    stub(Simpleton).fork {true}
    stub(Process).waitall do
      [ [1, stub!.success? {true}.subject],
        [2, stub!.success? {true}.subject] ]
    end

    Simpleton.run
  end

  should "call Process.exit(1) when some of its children exit unsuccessfully" do
    stub(Simpleton).fork {true}
    stub(Process).waitall do
      [ [1, stub!.success? {false}.subject],
        [2, stub!.success? {true}.subject] ]
    end

    mock(Process).exit(1) {true}

    Simpleton.run
  end

  context "with no arguments" do
    should "pass Simpleton::CommandRunners::PercentX as the command runner to each Worker created" do
      stub(Simpleton).fork { |block| block.call }
      stub(Simpleton::CommandRunners::PercentX).run {true}
      Simpleton::MiddlewareChains.each do |host, chain|
        mock.proxy(Simpleton::Worker).new(anything, anything, Simpleton::CommandRunners::PercentX)
      end

      Simpleton.run
    end
  end

  context "with an argument" do
    should "construct a new Worker in process with the argument as the command runner" do
      command_runner = Object.new
      def command_runner.run(*args); true; end

      stub(Simpleton).fork { |block| block.call }
      Simpleton::MiddlewareChains.each do |host, chain|
        mock.proxy(Simpleton::Worker).new(anything, anything, command_runner)
      end

      Simpleton.run(command_runner)
    end
  end
end

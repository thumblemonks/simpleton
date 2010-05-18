require 'test_helper'

context "Simpleton" do
  setup { Simpleton }
  asserts_topic.responds_to :configure
  asserts_topic.responds_to :use
  asserts_topic.responds_to :run

  asserts("that Simpleton::Configuration") { Simpleton::Configuration }.kind_of(Hash)
  asserts("that Simpleton::MiddlewareChains") { Simpleton::MiddlewareChains }.kind_of(Hash)

  asserts("that Simpleton::CommandRunner is autoloaded") { Simpleton::CommandRunner }
  asserts("that Simpleton::Worker is autoloaded") { Simpleton::Worker }
end

context "Simpleton.configure" do
  desired_configuration = { :foo => "bar", :hello => "world" }
  setup do
    Simpleton.configure { |config| config.merge!(desired_configuration) }
  end

  should("set Simpleton::Configuration appropriately") do
    Simpleton::Configuration
  end.equals(desired_configuration)

  teardown { Simpleton::Configuration.clear }
end

context "Simpleton.use(middleware)" do
  setup do
    Simpleton.configure { |config| config[:hosts] = ["app1", "app2", "app3"] }
    @middleware = Proc.new {""}
  end

  context "when the :only option is not specified" do
    setup { Simpleton.use @middleware }

    should "add the middleware to every location's chain" do
      Simpleton::Configuration[:hosts].all? do |host|
        Simpleton::MiddlewareChains[host].detect { |middleware| middleware == @middleware }
      end
    end
  end

  context "when the :only option is specified" do
    setup do
      @applicable_hosts = ["app2"]
      Simpleton.use @middleware, :only => @applicable_hosts
    end

    should "add the middleware to the hosts specified by :only" do
      @applicable_hosts.all? do |host|
        Simpleton::MiddlewareChains[host].detect { |middleware| middleware == @middleware }
      end
    end

    should "not add the middleware to hosts that are not specified by :only" do
      non_applicable_hosts = Simpleton::Configuration[:hosts] - @applicable_hosts
      non_applicable_hosts.all? do |host|
        !Array(Simpleton::MiddlewareChains[host]).detect { |middleware| middleware == @middleware }
      end
    end
  end

  context "when a user is explicitly set" do
    setup do
      Simpleton.configure { |config| config[:user] = "user#{Time.now.to_i}" }
      Simpleton.use @middleware
    end

    should "include the user in the key for MiddlewareChains" do
      Simpleton::Configuration[:hosts].all? do |host|
        Simpleton::MiddlewareChains.key? "#{Simpleton::Configuration[:user]}@#{host}"
      end
    end
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

  should "fork a new process for each configured location" do
    mock(Simpleton).fork.times(Simpleton::MiddlewareChains.keys.length) {true}
  
    Simpleton.run
  end
  
  should "construct a Worker for each location with the appropriate middleware chain" do
    stub(Simpleton).fork { |block| block.call }
    Simpleton::MiddlewareChains.each do |location, chain|
      mock(Simpleton::Worker).new(location, chain, anything) { mock!.run }
    end

    Simpleton.run
  end

  should "run each constructed Worker" do
    stub(Simpleton).fork { |block| block.call }
    Simpleton::MiddlewareChains.each do |location, chain|
      stub(Simpleton::Worker).new { mock!.run }
    end

    Simpleton.run
  end

  should "wait for all its children to return" do
    stub(Simpleton).fork {true}
    mock.proxy(Process).waitall

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

  should "pass Simpleton::CommandRunner as the command runner to each Worker created when called with no arguments" do
    stub(Simpleton).fork { |block| block.call }
    stub(Simpleton::CommandRunner).run {true}
    Simpleton::MiddlewareChains.each do |location, chain|
      mock.proxy(Simpleton::Worker).new(anything, anything, Simpleton::CommandRunner)
    end

    Simpleton.run
  end

  should "pass its argument as the command runner to each Worker created" do
    command_runner = Object.new
    def command_runner.run(*args); true; end

    stub(Simpleton).fork { |block| block.call }
    Simpleton::MiddlewareChains.each do |location, chain|
      mock.proxy(Simpleton::Worker).new(anything, anything, command_runner)
    end

    Simpleton.run(command_runner)
  end

  teardown do
    Simpleton::Configuration.clear
    Simpleton::MiddlewareChains.clear
  end
end

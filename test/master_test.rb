require 'test_helper'

context "Simpleton::Master#configure" do
  desired_configuration = { :foo => "bar", :hello => "world" }
  setup do
    @master = Simpleton::Master.new
    @master.configure { |config| config.merge!(desired_configuration) }
  end

  should("set Simpleton::Configuration appropriately") do
    @master.configuration
  end.equals(desired_configuration)
end

context "Simpleton::Master#use(middleware)" do
  setup do
    @master = Simpleton::Master.new
    @master.configure { |config| config[:hosts] = ["app1", "app2", "app3"] }
    @middleware = Proc.new {""}
  end

  context "when the :only option is not specified" do
    setup { @master.use @middleware }

    should "add the middleware to every location's chain" do
      @master.configuration[:hosts].all? do |host|
        @master.middleware_chains[host].detect { |middleware| middleware == @middleware }
      end
    end
  end

  context "when the :only option is specified" do
    setup do
      @applicable_hosts = ["app2"]
      @master.use @middleware, :only => @applicable_hosts
    end

    should "add the middleware to the hosts specified by :only" do
      @applicable_hosts.all? do |host|
        @master.middleware_chains[host].detect { |middleware| middleware == @middleware }
      end
    end

    should "not add the middleware to hosts that are not specified by :only" do
      non_applicable_hosts = @master.configuration[:hosts] - @applicable_hosts
      non_applicable_hosts.all? do |host|
        !Array(@master.middleware_chains[host]).detect { |middleware| middleware == @middleware }
      end
    end
  end

  context "when a user is explicitly set" do
    setup do
      @master.configure { |config| config[:user] = "user#{Time.now.to_i}" }
      @master.use @middleware
    end

    should "include the user in the key for MiddlewareChains" do
      @master.configuration[:hosts].all? do |host|
        @master.middleware_chains.key? "#{@master.configuration[:user]}@#{host}"
      end
    end
  end
end

context "@master::Master#run" do
  setup do
    @master = Simpleton::Master.new
    @master.configure { |config| config[:hosts] = ["app1", "app2", "app3"] }
    @master.use Proc.new {""}
  end

  should "fork a new process for each configured location" do
    mock(@master).fork.times(@master.middleware_chains.keys.length) {true}
  
    @master.run
  end
  
  should "construct a Worker for each location with the appropriate middleware chain" do
    stub(@master).fork { |block| block.call }
    @master.middleware_chains.each do |location, chain|
      mock(Simpleton::Worker).new(location, chain, anything, anything) { mock!.run }
    end

    @master.run
  end

  should "run each constructed Worker" do
    stub(@master).fork { |block| block.call }
    @master.middleware_chains.each do |location, chain|
      stub(Simpleton::Worker).new { mock!.run }
    end

    @master.run
  end

  should "wait for all its children to return" do
    stub(@master).fork {true}
    mock.proxy(Process).waitall

    @master.run
  end

  should "return true when all its children exit successfully" do
    stub(@master).fork {true}
    stub(Process).waitall do
      [ [1, stub!.success? {true}.subject],
        [2, stub!.success? {true}.subject] ]
    end

    @master.run
  end

  should "call Process.exit(1) when some of its children exit unsuccessfully" do
    stub(@master).fork {true}
    stub(Process).waitall do
      [ [1, stub!.success? {false}.subject],
        [2, stub!.success? {true}.subject] ]
    end

    mock(Process).exit(1) {true}

    @master.run
  end

  should "pass Simpleton::CommandRunner as the command runner to each Worker created when called with no arguments" do
    stub(@master).fork { |block| block.call }
    stub(Simpleton::CommandRunner).run {true}
    @master.middleware_chains.each do |location, chain|
      mock.proxy(Simpleton::Worker).new(anything, anything, Simpleton::CommandRunner, anything)
    end

    @master.run
  end

  should "pass its argument as the command runner to each Worker created" do
    command_runner = Object.new
    def command_runner.run(*args); true; end

    stub(@master).fork { |block| block.call }
    @master.middleware_chains.each do |location, chain|
      mock.proxy(Simpleton::Worker).new(anything, anything, command_runner, anything)
    end

    @master.run(command_runner)
  end
end

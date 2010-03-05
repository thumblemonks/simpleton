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
      asserts("that it") { Simpleton.use(Class.new) }.raises(ArgumentError, /would not apply/)
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
      @middleware = Proc.new {}
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
    end.raises(ArgumentError, /some.*are not configured/i)
  end

  teardown do
    Simpleton::Configuration.clear
    Simpleton::MiddlewareChains.clear
  end
end

context "Simpleton.run" do
  setup do
    Simpleton.configure { |config| config[:hosts] = ["app1", "app2", "app3"] }
    Simpleton.use Proc.new {}
  end

  should "fork a new process for each configured host" do
    mock(Simpleton).fork.times(Simpleton::Configuration[:hosts].length) { true }

    Simpleton.run
  end

  should "wait for all its children" do
    stub(Simpleton).fork {true}
    mock.proxy(Process).waitall

    Simpleton.run
  end

  should "construct a Worker for the host in the child process appropriately" do
    stub(Simpleton).fork { |block| block.call }
    Simpleton::MiddlewareChains.each do |host, chain|
      mock.proxy(Simpleton::Worker).new(host, chain)
    end

    Simpleton.run
  end

  should "run each Worker constructed in the child process" do
    stub(Simpleton).fork { |block| block.call }
    Simpleton::MiddlewareChains.each do |host, chain|
      stub(Simpleton::Worker).new(host, chain) { mock!.run }
    end

    Simpleton.run
  end
end

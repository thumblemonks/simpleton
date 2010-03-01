require 'test_helper'
require 'simpleton'

context "Simpleton" do
  setup { Simpleton }
  asserts_topic.responds_to :configure
  asserts_topic.responds_to :use

  asserts("that Simpleton::Configuration") { Simpleton::Configuration }.kind_of(Hash)
  asserts("that Simpleton::MiddlewareChains") { Simpleton::MiddlewareChains }.kind_of(Hash)
  asserts("that Simpleton::MiddlewareChains's default value") { Simpleton::MiddlewareChains[Time.now] }.equals([])
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
  end
end

[nil, []].each do |invalid_hosts_value|
  context "When the hosts are #{invalid_hosts_value.inspect}," do
    setup { Simpleton.configure { |config| config[:hosts] = invalid_hosts_value } }

    context "Simpleton.use" do
      asserts("that it") { Simpleton.use(Class.new) }.raises(ArgumentError, /would not apply/)
    end
  end
end

context %Q[When the hosts are ["app1", "app2", "app3"],] do
  setup do
    Simpleton.configure { |config| config[:hosts] = ["app1", "app2", "app3"] }
  end

  context "Simpleton.use(middleware)" do
    setup do
      @middleware_class = Class.new
      Simpleton.use @middleware_class
    end

    should "add an instance of the middleware to each host's chain" do
      Simpleton::Configuration[:hosts].all? do |host|
        Simpleton::MiddlewareChains[host].detect { |middleware| middleware.instance_of?(@middleware_class) }
      end
    end

    should "add only 1 instance of the middleware in each host's chain" do
      Simpleton::Configuration[:hosts].all? do |host|
        1 == Simpleton::MiddlewareChains[host].select { |middleware| middleware.instance_of?(@middleware_class) }.size
      end
    end

    should "ensure that the instance of the middleware in each chain is a different object" do
      middleware_instances_object_ids = Simpleton::Configuration[:hosts].map do |host|
        Simpleton::MiddlewareChains[host].detect { |middleware| middleware.instance_of?(@middleware_class) }
      end.map { |instance| instance.object_id }

      middleware_instances_object_ids.sort.uniq == middleware_instances_object_ids.sort
    end

    teardown { Simpleton::MiddlewareChains.clear }
  end

  context %Q[Simpleton.use(middleware, :only => ["app2"])] do
    setup do
      @middleware_class = Class.new
      @applicable_hosts = ["app2"]
      Simpleton.use @middleware_class, :only => @applicable_hosts
    end

    should "add an instance of the middleware to the specified hosts" do
      @applicable_hosts.all? do |host|
        Simpleton::MiddlewareChains[host].detect { |middleware| middleware.instance_of?(@middleware_class) }
      end
    end

    should "not add an instance of the middleware to hosts not specified" do
      non_applicable_hosts = Simpleton::Configuration[:hosts] - @applicable_hosts
      non_applicable_hosts.all? do |host|
        !Simpleton::MiddlewareChains[host].detect { |middleware| middleware.instance_of?(@middleware_class) }
      end
    end

    should "add only 1 instance of the middleware to each specified host's chain" do
      @applicable_hosts.all? do |host|
        1 == Simpleton::MiddlewareChains[host].select { |middleware| middleware.instance_of?(@middleware_class) }.size
      end
    end

    should "ensure that the instance of the middleware in each specified host's chain is a different object" do
      middleware_instances_object_ids = @applicable_hosts.map do |host|
        Simpleton::MiddlewareChains[host].detect { |middleware| middleware.instance_of?(@middleware_class) }
      end.map { |instance| instance.object_id }

      middleware_instances_object_ids.sort.uniq == middleware_instances_object_ids.sort
    end
  end

  context %Q[Simpleton.use(middleware, :only => ["not_configured"])] do
    asserts("that it") do
      Simpleton.use(@middleware_class, :only => ["not_configured"])
    end.raises(ArgumentError, /some.*are not configured/i)
  end
end

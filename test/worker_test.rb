require 'test_helper'

context "Simpleton::Worker.new" do
  location = "user@host"
  middleware_queue = [ Proc.new {"echo 123"} ]
  configuration = { :a => :b }

  context "with arguments (#{location}, #{middleware_queue.inspect}, #{configuration})" do
    setup { Simpleton::Worker.new(location, middleware_queue, configuration) }

    asserts(:location).equals(location)
    asserts(:middleware_queue).equals(middleware_queue)
    asserts(:configuration).equals(configuration)
  end
end

context "Simpleton::Worker#run" do
  location = "user@host"
  middleware_queue = [ Proc.new {"echo 123"}, Proc.new {"echo `date`"} ]
  configuration = { :a => :b }
  setup { Simpleton::Worker.new(location, middleware_queue, configuration) }

  should "call each middleware in the queue with the worker's configuration" do
    stub(topic).log_command { true }
    stub(topic).execute { ["", ""] }
    stub.instance_of(Session::Sh).exit_status { 0 }

    middleware_queue.each do |middleware|
      mock.proxy(middleware).call(configuration)
    end

    topic.run
  end

  should "execute the result of calling each middleware at the worker's location" do
    stub(topic).log_command { true }
    stub.instance_of(Session::Sh).exit_status { 0 }

    middleware_queue.each do |middleware|
      mock(topic).execute(anything, location, middleware.call) { ["", ""] }
    end

    topic.run
  end

  should "exit with the status of the first command that fails" do
    stub(topic).log_command { true }
    stub(topic).execute { ["", ""] }
    status = Time.now.to_i
    stub.instance_of(Session::Sh).exit_status { status }

    mock(Process).exit(status).any_number_of_times { true }

    topic.run
  end

  should "log each command executed" do
    stub(topic).execute { ["", ""] }
    stub.instance_of(Session::Sh).exit_status { 0 }

    middleware_queue.each do |middleware|
      mock(topic).log_command(middleware.call) { true }
    end

    topic.run
  end

  should "log the output of each command executed" do
    stdout, stderr = "Out #{Time.now.to_i}", "Err #{Time.now.to_i}"
    stub(topic).log_command { true }
    stub(topic).execute { [stdout, stderr] }
    stub.instance_of(Session::Sh).exit_status { 0 }

    mock(topic).log_output(stdout, stderr).twice { true }

    topic.run
  end
end

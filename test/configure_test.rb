require 'test_helper'
require 'simpleton'

context "Simpleton" do
  setup { Simpleton }
  asserts_topic.responds_to :configure
end

context "Simpleton.configure" do
  context "with a block operating on a single argument" do
    setup do
      @desired_configuration = { :foo => "bar", :hello => "world" }
      Simpleton.configure  do |config|
        config.merge!(@desired_configuration)
      end
    end

    asserts("that it sets Simpleton::Configuration appropriately") do
      Simpleton::Configuration
    end.equals { @desired_configuration }
  end
end

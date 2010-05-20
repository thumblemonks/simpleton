require 'test_helper'

context "Simpleton" do
  setup { Simpleton }
  asserts_topic.responds_to :configure
  asserts_topic.responds_to :use
  asserts_topic.responds_to :run

  asserts("that Simpleton::Master is autoloaded") { Simpleton::Master }
  asserts("that Simpleton::Master is autoloaded") { Simpleton::Middleware }
  asserts("that Simpleton::Worker is autoloaded") { Simpleton::Worker }
end

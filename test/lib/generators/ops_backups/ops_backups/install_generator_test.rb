require "test_helper"
require "generators/ops_backups/install/install_generator"

module OpsBackups
  class OpsBackups::InstallGeneratorTest < Rails::Generators::TestCase
    tests OpsBackups::InstallGenerator
    destination Rails.root.join("tmp/generators")
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end

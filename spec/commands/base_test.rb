# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "base commands functionality" do
  
  it "should read the configuration when its prompted for config (no relaod)" do
    configuration_path = File.expand_path(File.join(CONF_PATH, SETTINGS_FILE))
    File.expects(:exists?).with(configuration_path).returns(true)
    YAML::expects(:load_file).with(configuration_path)
    my_command = Squidward::Command::Base.new()
    my_command.configuration
  end
  
  it "should return the existing configuration when its prompted for config (no relaod)" do
    configuration_path = File.expand_path(File.join(CONF_PATH, SETTINGS_FILE))
    File.expects(:exists?).with(configuration_path).returns(true)
    YAML::expects(:load_file).with(configuration_path).returns({:key => "value"})
    my_command = Squidward::Command::Base.new()
    my_command.configuration
    # I'm doing it twice and it should work the second time (returns the cached copy)
    my_command.configuration
  end
  
  it "should store configuration" do
    File.expects(:open).with(File.expand_path(File.join(CONF_PATH, SETTINGS_FILE)), "w+")
    FileUtils.expects(:mkpath).with(File.expand_path(CONF_PATH))
    my_command = Squidward::Command::Base.new()
    my_command.store_configuration({})
  end
end
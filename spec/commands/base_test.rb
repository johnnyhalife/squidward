# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "base commands functionality" do
  
  it "should prompt for AWS Credentials when they do not exist" do
    Squidward::Command::Base.any_instance.expects(:read_credentials).returns(false)
    Squidward::Command::Base.any_instance.expects(:ask_for_credentials).returns(["access_key", "secret_key"])
    Squidward::Command::Base.any_instance.expects(:store_credentials).with(["access_key", "secret_key"])
    my_command = Squidward::Command::Base.new()
  end
  
  it "should ask for credentials" do
    Squidward::Command::Base.any_instance.expects(:read_credentials).returns(true)
    my_command = Squidward::Command::Base.new()
    my_command.expects(:puts).with("Enter your AWS credentials.")
    my_command.expects(:print).with("Access Key ID: ")
    my_command.expects(:print).with("Secret Access Key: ")
    my_command.expects(:ask).returns("user")
    my_command.expects(:ask_for_password).returns("password")
    my_command.ask_for_credentials.should == ["user", "password"]
  end
  
  it "when asking for password should turn off echo and turn it on" do
    Squidward::Command::Base.any_instance.expects(:read_credentials).returns(true)
    my_command = Squidward::Command::Base.new()
    my_command.expects(:echo_off)
    my_command.expects(:echo_on)
    my_command.expects(:puts)
    my_command.expects(:ask).returns("password")
    my_command.ask_for_password.should == "password"
  end
  
  it "should read the configuration when its prompted for config (no relaod)" do
    Squidward::Command::Base.any_instance.expects(:read_credentials).returns(true)
    configuration_path = File.expand_path(File.join(CONF_PATH, SETTINGS_FILE))
    File.expects(:exists?).with(configuration_path).returns(true)
    YAML::expects(:load_file).with(configuration_path)
    my_command = Squidward::Command::Base.new()
    my_command.configuration
  end
  
  it "should return the existing configuration when its prompted for config (no relaod)" do
    Squidward::Command::Base.any_instance.expects(:read_credentials).returns(true)
    configuration_path = File.expand_path(File.join(CONF_PATH, SETTINGS_FILE))
    File.expects(:exists?).with(configuration_path).returns(true)
    YAML::expects(:load_file).with(configuration_path).returns({:key => "value"})
    my_command = Squidward::Command::Base.new()
    my_command.configuration
    # I'm doing it twice and it should work the second time (returns the cached copy)
    my_command.configuration
  end
  
  it "should store configuration" do
    Squidward::Command::Base.any_instance.expects(:read_credentials).returns(true)
    File.expects(:open).with(File.expand_path(File.join(CONF_PATH, SETTINGS_FILE)), "w+")
    FileUtils.expects(:mkpath).with(File.expand_path(CONF_PATH))
    my_command = Squidward::Command::Base.new()
    my_command.store_configuration({})
  end
  
  it "should read credentials when already there" do
    Squidward::Command::Base.any_instance.expects(:configuration).returns({:credentials => {:secret_key => "secret", :access_key => "access"}}).twice
    my_command = Squidward::Command::Base.new()
    my_command.read_credentials.should == ["access", "secret"]
  end 
  
  it "should store credentials after getting them" do
    Squidward::Command::Base.any_instance.expects(:read_credentials).returns(false)
    Squidward::Command::Base.any_instance.expects(:ask_for_credentials).returns(["access_key", "secret_key"])
    Squidward::Command::Base.any_instance.expects(:configuration).returns({:credentials => {}})
    Squidward::Command::Base.any_instance.expects(:store_configuration).returns()
    my_command = Squidward::Command::Base.new()
  end
end
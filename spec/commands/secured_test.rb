# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "secured commands functionality" do  
  it "should prompt for AWS Credentials when they do not exist" do
    Squidward::Command::Secured.any_instance.expects(:read_credentials).returns(false)
    Squidward::Command::Secured.any_instance.expects(:ask_for_credentials).returns(["access_key", "secret_key"])
    Squidward::Command::Secured.any_instance.expects(:store_credentials).with(["access_key", "secret_key"])
    my_command = Squidward::Command::Secured.new()
  end
  
  it "should ask for credentials" do
    Squidward::Command::Secured.any_instance.expects(:read_credentials).returns(true)
    my_command = Squidward::Command::Secured.new()
    my_command.expects(:puts).with("Enter your AWS credentials.")
    my_command.expects(:print).with("Access Key ID: ")
    my_command.expects(:print).with("Secret Access Key: ")
    my_command.expects(:ask).returns("user")
    my_command.expects(:ask_for_password).returns("password")
    my_command.ask_for_credentials.should == ["user", "password"]
  end
  
  it "when asking for password should turn off echo and turn it on" do
    Squidward::Command::Secured.any_instance.expects(:read_credentials).returns(true)
    my_command = Squidward::Command::Secured.new()
    my_command.expects(:echo_off)
    my_command.expects(:echo_on)
    my_command.expects(:puts)
    my_command.expects(:ask).returns("password")
    my_command.ask_for_password.should == "password"
  end
      
  it "should read credentials when already there" do
    Squidward::Command::Secured.any_instance.expects(:configuration).returns({:credentials => {:secret_key => "secret", :access_key => "access"}}).twice
    my_command = Squidward::Command::Secured.new()
    my_command.read_credentials.should == ["access", "secret"]
  end 
  
  it "should store credentials after getting them" do
    Squidward::Command::Secured.any_instance.expects(:read_credentials).returns(false)
    Squidward::Command::Secured.any_instance.expects(:ask_for_credentials).returns(["access_key", "secret_key"])
    Squidward::Command::Secured.any_instance.expects(:configuration).returns({:credentials => {}})
    Squidward::Command::Secured.any_instance.expects(:store_configuration).returns()
    my_command = Squidward::Command::Secured.new()
  end
end
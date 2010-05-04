# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "credentials command functionality" do
  it "should clear the stored credentials" do
    my_command = Squidward::Command::Credentials.new()
    my_command.expects(:configuration).returns({:credentials => ["foo", "bar"]})
    my_command.expects(:store_configuration).with({:credentials => nil})
    my_command.clear
  end
  
  it "should store credentials" do
    Squidward::Command::Credentials.any_instance.expects(:read_credentials).returns(false)
    Squidward::Command::Credentials.any_instance.expects(:ask_for_credentials).returns({:credentials => ["foo", "bar"]})
    Squidward::Command::Credentials.any_instance.expects(:store_credentials).returns(true)

    my_command = Squidward::Command::Credentials.new()
    my_command.set
  end
end
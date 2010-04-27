# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "runner command functionality" do
  it "should clear the stored credentials" do
    my_command = Squidward::Command::Credentials.new()
    my_command.expects(:configuration).returns({:credentials => ["foo", "bar"]})
    my_command.expects(:store_configuration).with({:credentials => nil})
    my_command.clear
  end
end
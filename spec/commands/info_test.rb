# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "info command functionality" do
  it "should tell that is not configured when not configured" do
    Squidward::Command::Info.any_instance.expects(:read_credentials).returns(false)
    
    my_command = Squidward::Command::Info.new()
    my_command.expects(:puts).with("Not yet configured. Run 'squidward credentials:set' for configuring credentials.")
    my_command.index
  end
end
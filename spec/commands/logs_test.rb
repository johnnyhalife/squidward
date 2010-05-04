# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "log command functionality" do  
  it "should set backup default bucket" do
    my_command = Squidward::Command::Logs.new()
    my_command.expects(:system).with("tail -n 25 #{File.expand_path(File.join(CONF_PATH, LOG_FILE))}")
    my_command.index
  end
end
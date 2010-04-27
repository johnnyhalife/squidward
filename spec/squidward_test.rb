# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "launcher behavior" do  
  it "should invoke the proper command and method" do
    (command = mock).expects(:run)
    Squidward::Command::Mock.expects(:new).returns(command)
    Squidward::Command.run!("mock:run", nil)
  end
  
  it "should invoke index method as the default method when not provided" do
    (command = mock).expects(:index)
    Squidward::Command::Mock.expects(:new).returns(command)    
    Squidward::Command.run!("mock", nil)
  end
  
  it "should raise missing command when the method is invalid" do    
    Squidward::Command.expects(:puts).with("Unknown command. Run 'squidward help' for usage information.")
    Squidward::Command.run!("invalid", nil)
  end
  
  it "should raise missing command when the command action does not exist" do
    Squidward::Command.expects(:puts).with("Unknown command. Run 'squidward help' for usage information.")
    Squidward::Command::Mock.expects(:new).returns(mock)
    Squidward::Command.run!("mock:non-existing", nil)
  end
end
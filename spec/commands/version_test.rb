# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "runner command functionality" do
  before do 
    Squidward::Command::Version.any_instance.expects(:read_credentials).returns(["access_key", "secret_key"])
  end

  it "should show version string as {gem_name}-{version}" do
    my_command = Squidward::Command::Version.new()
    my_command.expects(:display).with("squidward-#{Squidward::Command::Version::GEM_VERSION}")
    my_command.index
  end
end
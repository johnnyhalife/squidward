# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "domain command functionality" do
  it "should inherit the Base functionality" do
    Squidward::Command::Domain.any_instance.expects(:read_credentials).returns(true)
    my_command = Squidward::Command::Domain.new()
  end
  
  it "should store backup for domain" do
    existing_domains = [{:domain => "domain", :vpath => "vpath"}]
    Squidward::Command::Domain.any_instance.expects(:read_credentials).returns(true)
    Squidward::Command::Domain.any_instance.expects(:configuration).returns({:domains => existing_domains})
    Squidward::Command::Domain.any_instance.expects(:store_configuration).with({:domains => existing_domains + [{:domain => "domain_name", :vpath => "virtual_path"}]})
    my_command = Squidward::Command::Domain.new()
    my_command.backup(["domain_name", "virtual_path"])
  end 
  
  it "should remove existing backup from the configuration and store new config" do
    existing_domains = [{:domain => "domain", :vpath => "vpath"}]
    Squidward::Command::Domain.any_instance.expects(:read_credentials).returns(true)
    Squidward::Command::Domain.any_instance.expects(:configuration).returns({:domains => existing_domains})
    Squidward::Command::Domain.any_instance.expects(:store_configuration).with({:domains => []})
    my_command = Squidward::Command::Domain.new()
    my_command.remove("domain")
  end
end
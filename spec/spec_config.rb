require 'spec'
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'lib/squidward'

require 'mock_command'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
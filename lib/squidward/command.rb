$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'commands/base'
Dir["#{File.dirname(__FILE__)}/commands/*"].each { |c| require c }
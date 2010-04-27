module Squidward
  module Command
    class Help < Base
      class HelpGroup < Array
        attr_reader :title

        def initialize(title)
          @title = title
        end

        def command(name, description)
          self << [name, description]
        end

        def space
          self << ['', '']
        end
      end

      def self.groups
        @groups ||= []
      end

      def self.group(title, &block)
        groups << begin
          group = HelpGroup.new(title)
          yield group
          group
        end
      end

      def self.create_default_groups!
        group 'General Commands' do |group|
          group.command 'help',                             'show this usage'
          group.command 'version',                          'show gem version'
          group.space
          group.command 'bucket:set <name>',                'set the S3 bucket where the files will be uploaded (default: backup, created when missing)'
          group.space
          group.command 'credentials:clear',                'clear the credentials stored on your settings'
          group.space
          group.command 'domain:backup <domain> [vpath] ',  'add aws_simpledb domain for backup [optional vpath a virtual path inside the bucket]'
          group.command 'domain:remove <domain>',           'remove aws_simpledb domain from backup list'
          group.space
          group.command 'run',                              'run the process by taking one by one the domains configured on your settings'        
          group.space
          group.command 'info',                             'display your current settings'
          group.command 'logs',                             'display lastest information from the log file'
        end
      end

      def index(args)
        display usage
      end

      def usage
        longest_command_length = self.class.groups.map do |group|
          group.map { |g| g.first.length }
        end.flatten.max

        self.class.groups.inject(StringIO.new) do |output, group|
          output.puts "=== %s" % group.title
          output.puts

          group.each do |command, description|
            if command.empty?
              output.puts
            else
              output.puts "%-*s # %s" % [longest_command_length, command, description]
            end
          end
          output.puts
          output
        end.string
      end
    end
  end
end

Squidward::Command::Help.create_default_groups!

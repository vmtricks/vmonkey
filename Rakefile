require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'mixlib/shellout'

module Rally
  module Mixin
    module ShellOut
      def shell_out(*command_args)
        cmd = Mixlib::ShellOut.new(command_args)
        cmd.live_stream = STDOUT
        cmd.run_command
        cmd
      end

      def shell_out!(*command_args)
        cmd= shell_out(*command_args)
        cmd.error!
        cmd
      end
    end
  end
end

include Rally::Mixin::ShellOut

ENV['VMONKEY_YML'] ||= File.expand_path(File.join(File.dirname(__FILE__), 'spec', 'integration', '.vmonkey'))

RSpec::Core::RakeTask.new(:unit) do |task|
  task.pattern = './spec/unit{,/*/**}/*_spec.rb'
end

RSpec::Core::RakeTask.new(:integration) do |task|
  task.pattern = './spec/integration{,/*/**}/*_spec.rb'
end

task :driver do
  shell_out! %Q{ruby ./spec/driver/driver.rb}
end

desc 'Run RSpec unit and integration tests'
task spec: [:unit, :integration, :driver]
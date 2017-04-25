require "open3"

require "safe_shell/version"
require "safe_shell/mock"

module SafeShell

  class << self
    def make_context(constants, libraries)
      { :constants => constants, :libraries => [libraries].flatten }
    end

    def run_test(test, cmd_test, mocks = [])
      variables = test[:constants].map{ |name, value| "#{name}=#{value}" }

      libs = test[:libraries].map{ |lib| "source #{lib}"}

      variables << 'SS_UNDER_TESTING=true'
      cmd = variables + libs + mocks
      cmd << cmd_test

      # `bash -c '#{cmd.join(' ; ')}'`
      safe_run(cmd)
    end

    def safe_run(cmds)
      stdout_err, status = Open3.capture2e("bash -c '#{cmds.join('; ')}'")

      raise 'Error in your script: ' + stdout_err if status.exitstatus.nonzero?

      stdout_err.strip
    end
  end
end

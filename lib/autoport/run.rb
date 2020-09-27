require "shellwords"

module Autoport
  class RunError < StandardError
    attr_reader :status
    def initialize(exit_status)
      @status = exit_status
      "Process exited with status #{exit_status.exitstatus}"
    end
  end

  # Runs a command, while blocking, like `system` does.
  # The output is shown on screen.
  # There is no redirection.
  #
  # Prefer using an array of multiple args, otherwise you are shelling out!
  def run(*cmd)
    if cmd.length > 1
      puts " $ #{cmd.shelljoin}"
    else
      puts " $ #{cmd.first}"
    end
    system(*cmd)

    unless $?.success?
      raise Autoport::RunError.new($?)
    end
  end
end

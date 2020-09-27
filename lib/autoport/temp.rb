require "fileutils"
require "tmpdir"

module Autoport::Temp
  extend self

  def dir_path()
    @dir
  end

  def dir()
    # Ruby's cleaning up behind us. How convenient!
    Dir.mktmpdir("mobile-nixos-autoporter") do |dir|
      @dir = dir
      Dir.chdir(dir) do
        yield
      end
    end
  end
end

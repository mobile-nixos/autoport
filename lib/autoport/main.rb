module Autoport
  extend self

  attr_reader :oem
  attr_reader :device

  INITIAL_PWD = Dir.pwd

  def out_dir(path = "")
    # Create it on access, reduces headaches.
    dir = File.join(INITIAL_PWD, "#{@oem}-#{@device}")
    FileUtils.mkdir_p(dir)
    File.join(dir, path)
  end

  def in_out_dir()
    Dir.chdir(out_dir) do
      yield
    end
  end

  def main(*args)
    unless ARGV.length == 2
      puts "Usage: autoport OEM DEVICE"
      exit 1
    end

    @oem = ARGV.shift
    @device = ARGV.shift

    # Work in the temp directory
    Temp.dir do
      Download.blob("bootimg/00_kernel", "boot.img")

      bootimg = Data::Bootimg.new("boot.img")

      if bootimg.kernel.config_file
        FileUtils.mkdir_p(out_dir("kernel"))
        FileUtils.cp(bootimg.kernel.config_file, out_dir("kernel/config.#{bootimg.kernel.architecture}"))
      else
        puts "WARNING: No kernel configuration found embedded in the kernel..."
      end

      device_file = DeviceFile.new(bootimg: bootimg)
      File.write(out_dir("default.nix"), device_file.get_contents)
    end
  end
end

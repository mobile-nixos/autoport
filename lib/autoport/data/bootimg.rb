module Autoport::Data
  # Handles cracking open a boot.img, and process parts of the data.
  class Bootimg
    def initialize(path)
      @path = path
      @unpacked = "#{@path}.unpacked"

      FileUtils.mkdir_p(@unpacked)
      Autoport.run("unpackbootimg", "-i", @path, "-o", @unpacked)
    end

    %i(
      base
      board
      cmdline
      hashtype
      header_version
      kernel_offset
      os_patch_level
      os_version
      pagesize
      ramdisk_offset
      second_offset
      tags_offset
    ).each do |key|
      define_method(key) do
        read_data(key)
      end
    end

    def get_path(key)
      Dir.glob(File.join(@unpacked, "*-#{key}")).first
    end

    def read_data(key)
      File.read(get_path(key))
    end

    def kernel()
      return @kernel if @kernel

      # We first need to extract the kernel, unless it's already been done
      unless File.exists?("kernel")
        filename = get_path("zImage").shellescape
        # While it's called `-zImage` it is not necessarily so.
        ft = `file --brief --mime-type #{filename}`.strip
        case ft
        when "application/x-lz4"
          Autoport.run("lz4cat < #{filename} > kernel")
        when "application/gzip"
          # zcat doesn't work here, it *has* to be gunzip
          Autoport.run("gunzip < #{filename} > kernel")
        when "application/octet-stream"
          case `file --brief #{filename}`.strip
          when /Linux kernel ARM64 boot executable Image/
            Autoport.run("cat < #{filename} > kernel")
          when /ARM OpenFirmware FORTH Dictionary/
            Autoport.run("binwalk", "-e", "#{filename}")
            Autoport.run("mv _#{filename}.extracted/* kernel")
          else
            STDERR.puts "ERROR: Don't know how to unpack file identified as 'octet stream'..."
            puts " -> #{detailed_ft}"
            Autoport.run("file", get_path("zImage"))
            exit 2
          end
        else
          STDERR.puts "ERROR: Don't know how to unpack #{ft} ..."
          Autoport.run("file", get_path("zImage"))
          exit 2
        end
      end

      @kernel = Autoport::Data::Kernel.new("kernel")
      @kernel
    end
  end
end

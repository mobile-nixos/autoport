module Autoport::Data
  # Handles extracting data from an *uncompressed* kernel image.
  class Kernel
    def initialize(path)
      @path = path
    end

    def knows_skip_initramfs?()
      `strings #{@path.shellescape}`.lines.grep(/skip_initramfs/).length > 0
    end

    def version_string()
      @version_string ||= `strings #{@path.shellescape}`
        .lines.grep(/Linux version [0-9]/).uniq.first
      @version_string
    end

    def version()
      version_string.split(/\s/)[2]
    end

    def architecture()
      info = `file #{@path.shellescape}`.strip
      case info
      when /ARM64/
        "aarch64"
      else
        STDERR.puts "WARNING: Architecture discovery failed.\n -> '#{info}'\n Assuming armv7l"
        "armv7l"
      end
    end

    def config_file()
      return @config_file if @config_file

      FileUtils.rm_rf("_#{@path}.extracted")
      Autoport.run("binwalk", "-e", @path)
      FileUtils.mkdir_p("#{@path}.extracted")
      Dir.chdir("_#{@path}.extracted") do
        Autoport.run("file *")
        config_file = `file *`.lines.select do |line|
          line.match(/Linux make config build file/)
        end.first

        if config_file
          @config_file = File.join(Dir.pwd, config_file.split(":").first)
        else
          nil
        end
      end
    end

    def config(name)
      value = File.read(config_file).lines.grep(/#{name}[ =]/).first
      value = value.strip if value
      case value
      when nil
        nil
      when /is not set/
        "n"
      when /=/
        value.split("=", 2).last
      else
        raise "Unexpected format for kernel config #{name}...\n->#{value}"
      end
    end
  end
end

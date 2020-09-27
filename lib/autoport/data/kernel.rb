module Autoport::Data
  # Handles extracting data from an *uncompressed* kernel image.
  class Kernel
    def initialize(path)
      @path = path
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
        raise "Architecture discovery failed.\n -> '#{info}'"
      end
    end

    def config_file()
      return @config_file if @config_file

      Autoport.run("binwalk", "-e", @path)
      FileUtils.mkdir_p("#{@path}.extracted")
      Dir.chdir("_#{@path}.extracted") do
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
  end
end

module Autoport::Data
  class Props
    # This order for files defines the priority of a redefined value.
    KNOWN_PATHS = %w[
      system/build.prop
      system/default.prop
      system/product/build.prop
      system/system/build.prop
      system/system/product/build.prop
      system/system/system_ext/build.prop
      system/vendor/build.prop
      vendor/build.prop
      vendor/default.prop
      vendor/odm/etc/build.prop
      boot/ramdisk/prop.default
      system/system/etc/prop.default
    ]

    def parse_content(content)
      # Removes comments (naïvely) and strips the line
      content.lines.map do |line|
        line.gsub(/#.*$/, "").strip()
      end
        .select { |line| line != "" }  # Then keep only legit lines
        .select { |line| !line.match(/^import /)  } # Skip imports, we can't handle them
        .map do |line|
          # Then split on first =
          line.split("=", 2)
        end
          .to_h  # convert to Hash
    end

    def initialize(sources)
      @data = sources.map do |pair|
        source, content = pair
        parse_content(content)
        [source, parse_content(content)]
      end
    end

    def get_prop(name)
      candidates = @data.select do |pair|
        source, props = pair
        props.has_key?(name)
      end
      
      if candidates.length > 1
        STDERR.puts "Warning: #{name} has multiple definitions (#{candidates.map(&:first).join(", ")})"
      end

      if candidates.length == 0
        nil
      else
        candidates.first.last[name]
      end
    end

    def keys()
      @data.map(&:last).map(&:keys).reduce(&:concat).sort.uniq
    end

    def all()
      keys.map do |k|
        [k, get_prop(k)]
      end.to_h
    end

    def self.from_files(files)
      self.new(files.map do |file|
        [file, File.read(file)]
      end)
    end
  end
end

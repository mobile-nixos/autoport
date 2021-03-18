require "json"

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

  def first_of_props(candidates)
    candidates.map { |prop| @props.get_prop(prop) }
      .select { |v| !!v }
      .first
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
      # First, we work with the boot.img file
      Download.blob("bootimg/00_kernel", "boot.img")

      # Keep it around for its accessors
      bootimg = Data::Bootimg.new("boot.img")

      # And extract its kernel config
      if bootimg.kernel.config_file
        FileUtils.mkdir_p(out_dir("kernel"))
        FileUtils.cp(bootimg.kernel.config_file, out_dir("kernel/config.#{bootimg.kernel.architecture}"))
      else
        puts "WARNING: No kernel configuration found embedded in the kernel..."
      end

      # Then, we want to work with device props
      prop_files = Data::Props::KNOWN_PATHS.map do |path|
        downloaded = File.join("_props", path)
        dir = File.dirname(downloaded)
        filename = File.basename(downloaded)
        FileUtils.mkdir_p(dir)
        begin
          Download.blob(path, downloaded)
          downloaded
        rescue Errno::ENOENT, Autoport::RunError
          nil
        end
      end
        .select { |path| !!path }
        .select do |path|
          # We have downloaded a symlink from gitlab? (leaky abstraction)
          file_content = File.read(path)
          !(file_content.strip.match(%r{/}) && file_content.strip.lines.length == 1)
        end
      @props = Data::Props.from_files(prop_files)


      # Get the CPU among those props, first found is fine.
      soc = first_of_props([
        "ro.vendor.mediatek.platform",
        "ro.board.platform",
        # The following is unlikely to be the right answer, but is a last chance to get an answer.
        "ro.product.board",
      ]).downcase

      soc =
        case soc
        when /^msm/, /^sdm/
          "qualcomm-#{soc}"
        when /^mt/
          "mediatek-#{soc}"
        else
          STDERR.puts "Warning, could not identify SOC vendor for #{soc}..."
          soc
        end

      manufacturer = first_of_props(%w[
        ro.product.vendor.manufacturer
        ro.product.system.manufacturer
        ro.product.manufacturer
      ])

      model = first_of_props([
        # Vendor-preferred names
        "ro.semc.product.name", # Sony
        "ro.display.series",
        "ro.product.display", # Motorola

        # Generic fields
        "ro.product.vendor.model",
        "ro.product.system.model",
        "ro.product.model",
      ])

      board = first_of_props([
        "ro.build.product",
        "ro.product.odm.device",
        "ro.product.vendor.name",
        "ro.product.name",
        "ro.product.board",
      ]).downcase

      oem = first_of_props([
        "ro.product.vendor.brand",
        "ro.product.brand",
        "ro.product.vendor.manufacturer",
        "ro.product.manufacturer",
      ]).downcase.gsub(/[^a-z]/, "_")

      ab_update = first_of_props([
        "ro.build.ab_update"
      ]) == "true"

      system_root_image = first_of_props([
        "ro.build.system_root_image"
      ]) == "true"

      device_name = first_of_props([
        "ro.build.product",
        "ro.product.device",
      ])

      # Finally, generate a device config file!
      device_file = DeviceFile.new(
        bootimg: bootimg,
        full_codename: "#{oem}-#{board}",
        soc: soc,
        manufacturer: manufacturer,
        model: model,
        has_vendor_partition: !!@props.get_prop("ro.product.vendor.device"),
        system_root_image: system_root_image,
        ab_update: ab_update,
        device_name: device_name,
      )

      File.write(out_dir("oem_props.json"), JSON.pretty_generate(@props.all))

      File.write(out_dir("default.nix"), device_file.get_contents)

      File.write(out_dir("misc.json"), JSON.pretty_generate({
        kernel_version: bootimg.kernel.version,
        kernel_version_string: bootimg.kernel.version_string,
      }))
    end

    puts ""
    puts "Generation done successfully in #{out_dir}"
  end
end

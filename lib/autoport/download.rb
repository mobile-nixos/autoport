# FIXME: This is *extremely* assuming use of the Android Dumps project.
module Autoport::Download
  extend self

  # TODO: download through ruby rather than through curl
  # TODO: Don't hardcode use of "head"
  # Download a blob
  def blob(path, out)
    Autoport.run(
      "curl",
      "--fail",
      "-o", out,
      head_blob_url(path)
    )
  end

  def head_blob_url(path)
    prefix = "#{Autoport.oem}/#{Autoport.device}"
    "https://git.rip/dumps/#{prefix}/-/raw/HEAD/#{path}?inline=false"
  end
end

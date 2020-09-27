#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("lib", __dir__)

require "autoport"

Autoport.main(*(ARGV.dup))

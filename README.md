Mobile NixOS Autoporter
=======================

* * *

**⚠️  This tool is work-in-progress.**

* * *

The goal of this tools is to kickstart an end-user's port to Mobile NixOS by
automating part of the tedious work of *searching for facts* about their
devices.

It will **not** produce instantly-bootable ports, but will vastly reduce the
amount of intel gathering.

* * *

## Usage

```
$ nix-shell
[nix-shell] $ ./autoport.rb $OEM $DEVICE
```

Where OEM and DEVICE represent values found (for the moment) at the *Android
Dumps* project.

 * https://git.rip/dumps/

The output of this is a directory in your `$PWD` named `$OEM-$DEVICE` which
holds the skeleton generated files.

For the time being, it does **not** generate a skeleton for the kernel builder
derivation, as there is no "template" per se to use. Start from a
`kernel/default.nix` from another device with a similar kernel version or a
similar SoC.

I would heavily suggest making the first commit in your commit series the
unmodified output of this tool, as a way to track required changes for this
output to be useful.

Be mindful and read the `/**/` comments! All of them are related to the
generation process! You will be asked to fill in some values that couldn't be
detected for the time being.

### Device name

Be mindful about the device name!

It can happen that the name detected differs from the name of the data source
used (Android Dumps).

It is likely that the detected name (`mobile.device.name`) is the preferred
name.

* * *

## Current design decisions

This current early version of the tool assumes the end-user will want to use
data from the *Android Dumps* project.

They are semi-standardized pre-extracted repositories made from the OEM system
images.

It does not require the end-user to trust the *Android Dumps* project, as it
only gathers **facts**, and does not use any of the code.

This mainly allows this project to skip the tedious work of figuring out the
diverse system image formats extraction procedures.

## Future goals

Extract different system image types ourselves to allow the end-user to work
from an image they choose.

Such images could be a TWRP-like recovery, a LineageOS-like custom rom, or
simply a system image they chose.

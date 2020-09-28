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

### A/B partition scheme

To verify, connect your device in fastboot mode to your computer.

```
fastboot getvar all 2>&1 | grep has-slot
(bootloader) has-slot:modem:yes
(bootloader) has-slot:system:yes
(bootloader) has-slot:boot:yes
```

If it has at least the `boot` slot, it is considered as using the  A/B
partition scheme.

It is **highly** unlikely it uses a discrete recovery partition if it uses the
A/B scheme for the boot image.

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

## Missing data points

### A/B partitions

From the unique datasource implemented, there is no way to detect whether
the device is using an A/B partition scheme.

The "best" way to do this would be to have the detection be done *online*
with the device in fastboot mode.

### Bad detection of "boot as recovery"

It happens that kernels may know about "skip_initramfs" while not actually
being in use by the device (e.g. motorola-addison).

This will need "online" detection, most likely.

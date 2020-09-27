Mobile NixOS Autoporter
=======================

* * *

**⚠️  This tool is work-in-process.**

* * *

The goal of this tools is to kickstart an end-user's port to Mobile NixOS by
automating part of the tedious work of *searching for facts* about their
devices.

It will **not** produce instantly-bootable ports, but will vastly reduce the
amount of intel gathering.

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

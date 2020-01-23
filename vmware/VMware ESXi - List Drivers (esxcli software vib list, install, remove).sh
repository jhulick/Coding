#!/bin/bash
# ------------------------------------------------------------
#
# ESXi Embedded Host Client
# 
# ------------------------------------------------------------
#
# The ESXi Embedded Host Client is a native HTML and JavaScript application and is served directly from your ESXi host! It should perform much better than any of the existing solutions.
#
# In short, a VIB is a software package that gets installed on a vSphere ESXi host that contains things like drivers. They have become quite a bit more common in the last few years as the supported hardware base for vSphere has increased over time.
# 
# 
# ------------------------------------------------------------


### !!! MAKE SURE TO DOUBLE CHECK THAT YOU'VE BACKED UP THE ESXI INSTANCE'S CURRENT VIB BEFORE MAKING CHANGES/UPDATES TO IT !!! ###

# ------------------------------------------------------------
#
### List/Show installed ESXi drivers (.vib extensioned files)
#
esxcli software vib list;

# ------------------------------------------------------------
#
### Install/Update target ESXi driver (.vib extensioned file)
#
esxcli software vib install -v "URL";

# ------------------------------------------------------------
#
### Remove target ESXi driver(s) (.vib extensioned files)
#
# software vib remove
#
# --dry-run            Performs a dry-run only. Report the VIB-level operations that would be performed, but do not change anything in the system.
#
# --force | -f         Bypasses checks for package dependencies, conflicts, obsolescence, and acceptance levels.
#                      Really not recommended unless you know what you are doing. Use of this option will result in a warning being displayed in the vSphere Client.
#
# --help | -h          Show the help message.
#
# --maintenance-mode   Pretends that maintenance mode is in effect. Otherwise, remove will stop for live removes that require maintenance mode.
#                      This flag has no effect for reboot required remediations.
#
# --no-live-install    Forces an remove to /altbootbank even if the VIBs are eligible for live removal. Will cause installation to be skipped on PXE-booted hosts.
#
# --vibname | -n       Specifies one or more VIBs on the host to remove. Must be one of the following forms: name, name:version, vendor:name, vendor:name:version.
#
esxcli software vib remove --vibname="NAME";


exit 0;

# ------------------------------------------------------------

### Ex) Update the ESXi's "Embedded Host Client"
###   |--> Download & install the latest HTTP & Javascript ".vib" file
esxcli software vib install -v "http://download3.vmware.com/software/vmw-tools/esxui/esxui-signed-latest.vib";

### Ex) Update the ESXi driver for various hardware (to ESXi v6.5/v6.7 latest as-of Jan-2020)
esxcli software vib install -v "https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/esx/vmw/vib20/misc-drivers/VMW_bootbank_misc-drivers_6.7.0-2.48.13006603.vib";

### Ex) Update the ESXi driver for NIC "net-r8168"
esxcli software vib install -v "https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/esx/vmw/vib20/net-r8168/VMware_bootbank_net-r8168_8.013.00-3vmw.510.0.0.799733.vib";


### Ex) Remove specific network driver(s)
esxcli software vib remove --vibname="net51-r8169";
esxcli software vib remove --vibname="net51-sky2";


# ------------------------------------------------------------
# Citation(s)
# 
#   flings.vmware.com  |  "ESXi Embedded Host Client"  |  https://flings.vmware.com/esxi-embedded-host-client#instructions
# 
# ------------------------------------------------------------
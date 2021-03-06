#!/bin/bash
# ------------------------------------------------------------
#
#  Restarting iDRAC via SSH
#


# iDRAC v8
racadm racreset soft
racadm racreset hard -f


# iDRAC v_?
racadm reset -h


# ------------------------------------------------------------
#
#  Disabling functionality for PCI devices which jack up the fan speed on PowerEdge Servers

#
# Get the current thermal settings
#

racadm get system.thermalsettings

racadm get system.thermalsettings.ThirdPartyPCIFanResponse
#  ^ Returns Enabled (1) or Disabled (0)


racadm set system.thermalsettings.ThirdPartyPCIFanResponse 0
#  ^ Disable PCI fan response


# ------------------------------------------------------------
#
# Fixing unnecesarilly high fan speeds on Dell PowerEdge R730xd Server(s)
#   |--> MCavallo, 20200625T081712
#   |-->  To resolve this, I ended up having to perform the following steps (as setting the temperature/fan speed settings the way they should be wasn't getting applied, and needed this order-of-events before it would "stick")
#
#
#         > Browse to iDRAC
#          > Launch remote Java IPMI connection
#
#
#         > Browse to ESXI (host OS)
#          > Shut down all VMs
#           > Enter Maintenance mode
#            > Reboot server
#
#
#         > Enter "System Setup" (BIOS) during bootup (F2) 
#          > System Settings
#           > System Profile
#            > Set to "Performance per Watt (OS)"
#             > Save and Exit (Reboot Server)
#
#
#         > Browse to iDRAC
#          > On the left navigation within iDRAC, dropdown the Hardware section (hit the + next to it)
#           > Select "Fans" under the Hardware dropdown
#            > At the top of the window, select "Setup" (or similar sounding option)
#             > Modify EVERY value to anything other than what they're currently set-to (just to trigger ANY change on each value) - I speculate that a BIOS update may have corrupted these values
#              > Click "Apply" (bottom-right)
#               > Popup appears asking to reboot to apply changes, select "Reboot Now"
#             > Repeat these steps except on the Fan "Setup" page, apply the following configuration:
#              > Set "Thermal Profile" to "Minimum Power"
#              > Set "Maximum Exhaust Temperature Limit" to "Default (70 deg-C)"
#              > Set "Fan Speed Offset" to "Off"
#              > Set "Minimum Fan Speed in PWM" to "Default"
#               > Click "Apply" (bottom-right)
#                > Popup appears asking to reboot to apply changes, select "Reboot Now"
#
#
#         > SSH into iDRAC
#          > Run command "racadm racreset soft" to restart iDRAC and fully apply new configuration
#
#
# ------------------------------------------------------------
#
# Citation(s)
#
#   www.dell.com  |  "Integrated Dell Remote Access Controller 8 (iDRAC8) and iDRAC7 v2.20.20.20 User's Guide"  |  https://www.dell.com/support/manuals/us/en/04/idrac7-8-with-lc-v2.20.20.20/idrac8_2.10.10.10_ug-v2/modifying-thermal-settings-using-racadm?guid=guid-476e0462-fb31-4dac-be4a-3af3801ae556&lang=en-us
#
#   www.dell.com  |  "PowerEdge R730xd cooling / fan noise issue - Dell Community"  |  https://www.dell.com/community/PowerEdge-Hardware-General/PowerEdge-R730xd-cooling-fan-noise-issue/td-p/7187458
#
#   www.dell.com  |  "Solved: r730xd excessive fan speed - Dell Community"  |  https://www.dell.com/community/PowerEdge-Hardware-General/r730xd-excessive-fan-speed/td-p/4586254
#
#   www.dell.com  |  "Solved: Re: racadm racreset vs Reset idrac - Dell Community"  |  https://www.dell.com/community/Systems-Management-General/racadm-racreset-vs-Reset-idrac/m-p/7315091#M27654
#
# ------------------------------------------------------------
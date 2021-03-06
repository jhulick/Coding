#!/bin/bash


# Define the common path for Unifi's "config.gateway.json" file on Debian distros (based on the 'unifi' Linux user)
UNIFI_HOMEDIR=$(getent passwd unifi | cut -d : -f 6);
CONFIG_DIR_1="${UNIFI_HOMEDIR:-/usr/lib/unifi}/sites/default";
CONFIG_DIR_2="${UNIFI_HOMEDIR:-/usr/lib/unifi}/data/sites/default";
CONFIG_GATEWAY_JSON_1="${CONFIG_DIR_1}/config.gateway.json";
CONFIG_GATEWAY_JSON_2="${CONFIG_DIR_2}/config.gateway.json";


# Show config.gateway.json filepaths (where they must be placed to function through Ubiquiti's UniFi Controller)
echo "";
echo "Info:  config.gateway.json (filepath option 1/2):  \"${CONFIG_GATEWAY_JSON_1}\"";
echo "Info:  Calling [ ls -al \"${CONFIG_DIR_1}\"; ] ...";
ls -al "${CONFIG_DIR_1}";
echo "";
echo "Info:  config.gateway.json (filepath option 2/2):  \"${CONFIG_GATEWAY_JSON_2}\"";
echo "Info:  Calling [ ls -al \"${CONFIG_DIR_2}\"; ] ...";
ls -al "${CONFIG_DIR_2}";
echo "";


# Create config.gateway.json (if it doesn't already exist)
test -h "${HOME}/config.gateway.json" && test ! -f "${HOME}/config.gateway.json" && touch "${HOME}/config.gateway.json";


# Set the file's access permissions & user/group permissions as-intended
chown "unifi:unifi" "${HOME}/config.gateway.json";
chmod 0640 "${HOME}/config.gateway.json";


# Link to the first-located site & it's designated config.gateway.json path
test -n "${UNIFI_HOMEDIR}" && test -d "${CONFIG_DIR_1}" && test -v HOME && ln -sf "${CONFIG_GATEWAY_JSON_1}" "${HOME}/config.gateway.json";
test -n "${UNIFI_HOMEDIR}" && test -d "${CONFIG_DIR_1}" && test -v SUDO_USER && SUDOER_HOMEDIR="$(getent passwd ${SUDO_USER} | cut -d : -f 6)" && ln -sf "${CONFIG_GATEWAY_JSON_1}" "${SUDOER_HOMEDIR}/config.gateway.json";
test -n "${UNIFI_HOMEDIR}" && test -d "${CONFIG_DIR_2}" && test -v HOME && ln -sf "${CONFIG_GATEWAY_JSON_2}" "${HOME}/config.gateway.json";
test -n "${UNIFI_HOMEDIR}" && test -d "${CONFIG_DIR_2}" && test -v SUDO_USER && SUDOER_HOMEDIR="$(getent passwd ${SUDO_USER} | cut -d : -f 6)" && ln -sf "${CONFIG_GATEWAY_JSON_2}" "${SUDOER_HOMEDIR}/config.gateway.json";


# ------------------------------------------------------------
#
# Citation(s)
#
#   docs.foxpass.com  |  "Ubiquiti Unifi / EdgeMax VPN Clients"  |  https://docs.foxpass.com/docs/ubiquiti-unifi-vpn-clients
#
#   community.ui.com/  |  "Create DNS enteries | Ubiquiti Community"  |  https://community.ui.com/questions/Create-DNS-enteries/ab712740-d579-4c89-824a-cda582a6bdd4?page=1
#
#   help.ubnt.com/  |  "UniFi - USG Advanced Configuration – Ubiquiti Networks Support and Help Center"  |  https://help.ubnt.com/hc/en-us/articles/215458888-UniFi-USG-Advanced-Configuration
#
# ------------------------------------------------------------
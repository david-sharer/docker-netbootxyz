#!/bin/bash

# Ownership
chmod +xrw /extra/*.sh

# Perform the initial configuration
/extra/init.sh

echo "            _   _                 _                      "
echo " _ __   ___| |_| |__   ___   ___ | |_  __  ___   _ ____  "
echo "| '_ \ / _ \ __| '_ \ / _ \ / _ \| __| \ \/ / | | |_  /  "
echo "| | | |  __/ |_| |_) | (_) | (_) | |_ _ >  <| |_| |/ /   "
echo "|_| |_|\___|\__|_.__/ \___/ \___/ \__(_)_/\_\__,  /___| "
echo "                                             |___/       "
printf '\e[1A %43s\n' 'w/ dnsmasq-dhcpproxy'

# if we have a customized conf, prefer that one
ORIGINAL_CONFIG="/etc/supervisor.conf"
CUSTOM_CONFIG="/extra/etc/supervisor.conf"
if [[ -e "$CUSTOM_CONFIG" ]]; then
  CUSTOM_CONFIG_LEN=$(wc -l <"$CUSTOM_CONFIG")
  # if our customized supervisor.conf is empty-ish, populate it with the current config
  if [ $CUSTOM_CONFIG_LEN -lt 2 ]; then
    echo "$CUSTOM_CONFIG length = $CUSTOM_CONFIG_LEN - Replacing with $ORIGINAL_CONFIG"
    cat <"$ORIGINAL_CONFIG" >"$CUSTOM_CONFIG"
  fi

  echo "Starting supervisord with $CUSTOM_CONFIG"
  supervisord -c "$CUSTOM_CONFIG"
else
  echo "Starting supervisord with $ORIGINAL_CONFIG"
  supervisord -c "$ORIGINAL_CONFIG"
fi

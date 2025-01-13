#!/bin/bash

# Collect script context & set root directory to repo root
DIR=$(dirname $0)
ROOT="$DIR/../../.."
cd "$ROOT"

#########################################
# Create the customization files        #
# If we don't do this under the current #
# user, docker likes to do it as root   #
#########################################

EXTRA_CONFIG_DIR="$DIR/state/extra"
if [[ ! -d "$EXTRA_CONFIG_DIR" ]]; then mkdir -p "$EXTRA_CONFIG_DIR"; fi

EXTRA_ETC_CONFIG_DIR="$EXTRA_CONFIG_DIR/etc"
if [[ ! -d "$EXTRA_ETC_CONFIG_DIR" ]]; then mkdir -p "$EXTRA_ETC_CONFIG_DIR"; fi

DNSMASQ_CONFIG="$EXTRA_CONFIG_DIR/etc/dnsmasq.conf"
if [[ ! -e "$DNSMASQ_CONFIG" ]]; then echo "# Add dnsmasq customizations here" >>"$DNSMASQ_CONFIG"; fi

EXTRA_SUPERVISORD_CONFIG="$EXTRA_ETC_CONFIG_DIR/supervisor.conf"
if [[ ! -e "$EXTRA_SUPERVISORD_CONFIG" ]]; then echo "# this file will be populated after first startup" >>"$EXTRA_SUPERVISORD_CONFIG"; fi

EXTRA_STARTUP_CONFIG="$EXTRA_CONFIG_DIR/start.sh"
if [[ ! -e "$EXTRA_STARTUP_CONFIG" ]]; then cat >>"$EXTRA_STARTUP_CONFIG" << EOF
#!/bin/bash

# Ownership
chmod +xrw /extra/*.sh

# Perform the initial configuration
/extra/init.sh

echo "            _   _                 _                      "
echo " _ __   ___| |_| |__   ___   ___ | |_  __  ___   _ ____  "
echo "| '_ \ / _ \ __| '_ \ / _ \ / _ \| __| \ \/ / | | |_  /  "
echo "| | | |  __/ |_| |_) | (_) | (_) | |_ _ >  <| |_| |/ /   "
echo "|_| |_|\___|\__|_.__/ \___/ \___/ \__(_)_/\_\\__,  /___| "
echo "                                             |___/       "
printf '\e[1A %43s\n' 'w/ $(basename $DIR)'

# if we have a customized conf, prefer that one
ORIGINAL_CONFIG="/etc/supervisor.conf"
CUSTOM_CONFIG="/extra/etc/supervisor.conf"
if [[ -e "\$CUSTOM_CONFIG" ]]; then
  CUSTOM_CONFIG_LEN=\$(wc -l <"\$CUSTOM_CONFIG")
  # if our customized supervisor.conf is empty-ish, populate it with the current config
  if [ \$CUSTOM_CONFIG_LEN -lt 2 ]; then
    echo "\$CUSTOM_CONFIG length = \$CUSTOM_CONFIG_LEN - Replacing with \$ORIGINAL_CONFIG"
    cat <"\$ORIGINAL_CONFIG" >"\$CUSTOM_CONFIG"
  fi

  echo "Starting supervisord with \$CUSTOM_CONFIG"
  supervisord -c "\$CUSTOM_CONFIG"
else
  echo "Starting supervisord with \$ORIGINAL_CONFIG"
  supervisord -c "\$ORIGINAL_CONFIG"
fi
EOF
fi

EXTRA_INIT_CONFIG="$EXTRA_CONFIG_DIR/init.sh"
if [[ ! -e "$EXTRA_INIT_CONFIG" ]]; then cat >>"$EXTRA_INIT_CONFIG" << EOF
#!/bin/bash
/init.sh
# Add init customizations here
EOF
fi


# make any scripts in the dir executable
chmod +x "$EXTRA_CONFIG_DIR"/*.sh

# Launch the local docker compose file
docker compose -f "$DIR/docker-compose.yml" up
#!/bin/bash
/init.sh

# This is pulled from https://github.com/netbootxyz/docker-netbootxyz/pull/73
# and modified to use our paths
if [ -n "${DHCP_RANGE_START}" ]; then
  echo "[netbootxyz-init] Enabling DHCP Proxy mode for DHCP_RANGE_START=${DHCP_RANGE_START}"

  # Get the container's IP address using hostname if not already set
  if [ -z "${CONTAINER_IP}" ]; then
    CONTAINER_IP=$(hostname -i)
    export CONTAINER_IP
  fi
  
  DNSMASQ_CONFIG="/extra/etc/dnsmasq.conf";
  DNSMASQ_CONFIG_TEMPLATE="/extra/etc/dnsmasq.template.conf";

  echo -e "# Do not modify this file directly. It is re-generated on every startup (from $DNSMASQ_CONFIG_TEMPLATE)\n" >"$DNSMASQ_CONFIG"
  envsubst <"$DNSMASQ_CONFIG_TEMPLATE" >>"$DNSMASQ_CONFIG"
fi
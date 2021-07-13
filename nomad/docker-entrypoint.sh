#!/usr/bin/dumb-init /bin/sh
set -e

CONSUL_DATA_DIR=/consul/data
CONSUL_CONFIG_DIR=/consul/config

NOMAD_DATA_DIR=/nomad/data
NOMAD_CONFIG_DIR=/nomad/config

# You can set CONSUL_BIND_INTERFACE to the name of the interface you'd like to
# bind to and this will look up the IP and pass the proper -bind= option along
# to Consul.
NOMAD_BIND=
if [ -n "$NOMAD_BIND_INTERFACE" ]; then
  NOMAD_BIND_ADDRESS=$(ip -o -4 addr list $NOMAD_BIND_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$NOMAD_BIND_ADDRESS" ]; then
    echo "Could not find IP for interface '$NOMAD_BIND_INTERFACE', exiting"
    exit 1
  fi

  NOMAD_BIND="-bind=$NOMAD_BIND_ADDRESS"
  echo "==> Found address '$NOMAD_BIND_ADDRESS' for interface '$NOMAD_BIND_INTERFACE', setting bind option..."
fi

# You can set CONSUL_CLIENT_INTERFACE to the name of the interface you'd like to
# bind client intefaces (HTTP, DNS, and RPC) to and this will look up the IP and
# pass the proper -client= option along to Consul.
NOMAD_CLIENT=
if [ -n "$NOMAD_CLIENT_INTERFACE" ]; then
  NOMAD_CLIENT_ADDRESS=$(ip -o -4 addr list $NOMAD_CLIENT_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$NOMAD_CLIENT_ADDRESS" ]; then
    echo "Could not find IP for interface '$NOMAD_CLIENT_INTERFACE', exiting"
    exit 1
  fi

  NOMAD_CLIENT="-client=$NOMAD_CLIENT_ADDRESS"
  echo "==> Found address '$NOMAD_CLIENT_ADDRESS' for interface '$NOMAD_CLIENT_INTERFACE', setting client option..."
fi

exec consul agent \
    -data-dir="$CONSUL_DATA_DIR" \
    -config-dir="$CONSUL_CONFIG_DIR" &

# You can also set the NOMAD_LOCAL_CONFIG environemnt variable to pass some
# Nomad configuration JSON without having to bind any volumes.
if [ -n "$NOMAD_LOCAL_CONFIG" ]; then
	echo "$NOMAD_LOCAL_CONFIG" > "$NOMAD_CONFIG_DIR/local.json"
fi

# If the user is trying to run Nomad directly with some arguments, then
# pass them to Nomad.
if [ "${1:0:1}" = '-' ]; then
    set -- nomad "$@"
fi

# Look for Nomad subcommands.
if [ "$1" = 'agent' ]; then
    shift
    set -- nomad agent \
        -data-dir="$NOMAD_DATA_DIR" \
        -config="$NOMAD_CONFIG_DIR" \
        $NOMAD_BIND \
        $NOMAD_CLIENT \
        "$@"
elif [ "$1" = 'version' ]; then
    # This needs a special case because there's no help output.
    set -- nomad "$@"
elif nomad --help "$1" 2>&1 | grep -q "nomad $1"; then
    # We can't use the return code to check for the existence of a subcommand, so
    # we have to use grep to look for a pattern in the help output.
    set -- nomad "$@"
fi

# If we are running Nomad
if [ "$1" = 'nomad' -a -z "${NOMAD_DISABLE_PERM_MGMT+x}" ]; then
    # If requested, set the capability to bind to privileged ports.
    # Note that this doesn't work with all
    # storage drivers (it won't work with AUFS).
    if [ ! -z ${NOMAD_ALLOW_PRIVILEGED_PORTS+x} ]; then
        setcap "cap_net_bind_service=+ep" /bin/nomad
    fi

    # set -- nomad "$@"
fi

exec "$@"

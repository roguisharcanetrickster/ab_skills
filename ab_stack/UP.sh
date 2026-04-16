#!/bin/bash

# Import ENV variables
set -o allexport
source .env
set +o allexport

File="docker-compose.yml"
STACKNAME="demo_ab"
# if [[ -n "$SYSTEMD_SERVICE" && -z $Dev ]]; then
# 	systemctl --user start ${SYSTEMD_SERVICE}.service
# el
if [ "$PLATFORM" = "podman" ]; then
   podman compose -f $File -p $STACKNAME up -d
else
   docker stack deploy -c $File $STACKNAME
fi

#!/usr/bin/env bash
# Uses the AB Migration Manager to update every tenant DB to the latest schema.
# Expects `docker compose` stack already up (see package.json start_ab).

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

set -o allexport
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/.env"
set +o allexport

set -eo pipefail

PLATFORM=${PLATFORM:-docker}
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-ab_stack}

usage() {
   echo "Usage: $(basename "$0") [-p COMPOSE_PROJECT_NAME] [-h]" >&2
   echo "  -p  override Docker Compose project name (default from .env: ${COMPOSE_PROJECT_NAME})" >&2
   echo "  -h  help" >&2
   exit 1
}

while getopts "p:h" name; do
   case $name in
   p) COMPOSE_PROJECT_NAME=$OPTARG ;;
   h) usage ;;
   ?) usage ;;
   esac
done
shift $((OPTIND - 1)) || true

${PLATFORM} pull docker.io/digiserve/ab-migration-manager:master

RUNNING=$(${PLATFORM} compose -p "${COMPOSE_PROJECT_NAME}" ps -q --status running api_sails 2>/dev/null || true)
if [ -z "${RUNNING}" ]; then
   echo "${COMPOSE_PROJECT_NAME}: no running api_sails. From ab_stack run: npm run start_ab" >&2
   exit 1
fi

NETWORK="${COMPOSE_PROJECT_NAME}_default"
if ! ${PLATFORM} network inspect "${NETWORK}" >/dev/null 2>&1; then
   echo "Network ${NETWORK} not found. Check COMPOSE_PROJECT_NAME matches docker compose project." >&2
   exit 1
fi

${PLATFORM} run --rm \
   --network="${NETWORK}" \
   -e MYSQL_PASSWORD \
   docker.io/digiserve/ab-migration-manager:master node app.js

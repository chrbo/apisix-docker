#!/bin/bash

set -eou pipefail

INOTIFYWAIT_FILES="${INOTIFYWAIT_FILES:-}"
INOTIFYWAIT_OPTIONS="${INOTIFYWAIT_OPTIONS:- --event modify,delete,delete_self}"
APISIX_CONFIG_FILE="${APISIX_CONFIG_FILE:-/apisix-config/apisix.yaml}"

# INOTIFYWAIT_FILES env var must be set.
if [[ -z "$INOTIFYWAIT_FILES" ]]; then
	echo "ERROR: Missing INOTIFYWAIT_FILES environment variable"
	exit 1
fi

inotifywait --monitor --recursive --format "%e %w%f" --event modify,delete,delete_self ${INOTIFYWAIT_FILES} | while read changed; do
  echo ${changed}
  /usr/bin/yq eval-all '. as $item ireduce ({}; . *+ $item)' /tmp/apisix-config-yaml-configmap/apisix.base.yaml /tmp/apisix-vault-configuration/apisix.ssls.yaml > ${APISIX_CONFIG_FILE} && echo \#END >> ${APISIX_CONFIG_FILE}
done

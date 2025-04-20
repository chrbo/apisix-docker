#!/bin/bash

set -eou pipefail

APISIX_CERTIFICATE_FOLDER="${APISIX_CERTIFICATE_FOLDER:-/input/certificates}"
APISIX_DESTINATION_CONFIG_FILE="${APISIX_DESTINATION_CONFIG_FILE:-/apisix-config/apisix.yaml}"
APISIX_SOURCE_CONFIG_FILES="${APISIX_SOURCE_CONFIG_FILE:-/input/config/*.yaml}"
INOTIFYWAIT_FILES="${INOTIFYWAIT_FILES:-/input}"
INOTIFYWAIT_OPTIONS="${INOTIFYWAIT_OPTIONS:- --event modify,delete,delete_self}"
MODE="${MODE:-init}"

function buildApisixConfig() {

  echo "Executing yq command eval-all \'. as \$item ireduce ({}; . *+ \$item)\'} with input files ${APISIX_SOURCE_CONFIG_FILES} to output file /tmp/apisix.yaml"
  yq eval-all '. as $item ireduce ({}; . *+ $item)' ${APISIX_SOURCE_CONFIG_FILES} > /tmp/apisix-step-1.yaml

  echo "Executing yq command (.. | select(has(\"file\"))) |= load_str(\"${APISIX_CERTIFICATE_FOLDER}/\" + .file) with input file /tmp/apisix-step-1.yaml to output file /tmp/apisix-step-2.yaml"
  yq "(.. | select(has(\"file\"))) |= load_str(\"${APISIX_CERTIFICATE_FOLDER}/\" + .file)" /tmp/apisix-step-1.yaml > /tmp/apisix-step-2.yaml

  echo "Move /tmp/apisix-step-2.yaml to ${APISIX_DESTINATION_CONFIG_FILE}"
  mv /tmp/apisix-step-2.yaml ${APISIX_DESTINATION_CONFIG_FILE}

}

echo "Mode is ${MODE}"

if [ "${MODE}" == "init" ]; then

  buildApisixConfig

elif [ "${MODE}" == "reload" ]; then

  if [[ -z "$INOTIFYWAIT_FILES" ]]; then
    echo "ERROR: Missing INOTIFYWAIT_FILES environment variable"
    exit 1
  fi

  inotifywait --monitor --recursive --format "%e %w%f" --event modify,delete,delete_self "${INOTIFYWAIT_FILES}" | while read -r changed; do
    echo "${changed}"
    buildApisixConfig
  done

fi

#!/bin/bash

set -eou pipefail

INOTIFYWAIT_FILES="${INOTIFYWAIT_FILES:-}"
INOTIFYWAIT_OPTIONS="${INOTIFYWAIT_OPTIONS:- --event modify,delete,delete_self}"
APISIX_SOURCE_CONFIG_FILE="${APISIX_SOURCE_CONFIG_FILE:-/input/apisix-config/apisix.base.yaml}"
APISIX_DESTINATION_CONFIG_FILE="${APISIX_DESTINATION_CONFIG_FILE:-/apisix-config/apisix.yaml}"
APISIX_CERTIFICATE_FOLDER="${APISIX_CERTIFICATE_FOLDER:-/input}"
YQ_COMMAND="${YQ_COMMAND:-(.. | select(has(\"file\"))) |= load_str(\"${APISIX_CERTIFICATE_FOLDER}/\" + .file)}"
MODE="${MODE:-init}"

function buildApisixConfig() {

  echo "Executing yq command ${YQ_COMMAND} with input file ${APISIX_SOURCE_CONFIG_FILE} to output file ${APISIX_DESTINATION_CONFIG_FILE}"
  yq "${YQ_COMMAND}" "${APISIX_SOURCE_CONFIG_FILE}" > "${APISIX_DESTINATION_CONFIG_FILE}"

}

#cat apps/testdev/apisix/configMap-test.yaml | yq '.data."apisix.base.yaml"' | yq '.routes[] |= select(.id == "kvb-offer-*").plugins.response-rewrite.body="{\"availableTypes\":[]}"' > apps/testdev/apisix/configMap-tmp2.yaml
#yq eval -P '.data."apisix.base.yaml" = load_str("apps/testdev/apisix/configMap-tmp2.yaml")' apps/testdev/apisix/configMap-test.yaml > apps/testdev/apisix/configMap-new.yaml

#yq '.routes[] |= (select(.id == "kvb-offer-*") | del(.plugins))' apps/testdev/apisix/configMap-tmp2.yaml > apps/testdev/apisix/configMap-tmp3.yaml

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

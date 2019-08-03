#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

CONF_FILE="${SCRIPT_DIR}/conf.txt"

if [ ! -f "${CONF_FILE}" ]; then
	echo "There is no conf.txt file."
	exit 1
fi

. ${CONF_FILE}



INSTANCE_NAME="$1"

if [ "${INSTANCE_NAME}" = "" ]; then
	echo "Instance name required." 1>&2
	exit 1
fi

gcloud compute --project "${PROJECT_NAME}" \
	instances create "${INSTANCE_NAME}" \
	--zone "asia-northeast1-b" \
	--machine-type "g1-small" \
	--image-family "debian-9" \
	--image-project "debian-cloud" \
	--metadata-from-file startup-script="${SCRIPT_DIR}/gce_setup/instance_install.sh"


echo -e '\nDNS setup start.\n'

${SCRIPT_DIR}/dns_setup/dns_setup.sh


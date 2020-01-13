#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

CONF_FILE="${SCRIPT_DIR}/conf.txt"

if [ ! -f "${CONF_FILE}" ]; then
	echo "There is no conf.txt file."
	exit 1
fi

. ${CONF_FILE}


INSTANCE_DEFAULT_CONF="${SCRIPT_DIR}/instance_conf.txt"
INSTANCE_CONF=${INSTANCE_DEFAULT_CONF}

INSTANCE_ZONE="asia-northeast1-b"
INSTANCE_MACHINE_TYPE="g1-small"
INSTANCE_IMAGE_FAMILY="debian-10"
INSTANCE_IMAGE_PROJECT="debian-cloud"
INSTANCE_PREEMPTIBLE=""

INSTANCE_NAME="$1"

if [ "${INSTANCE_NAME}" = "" ]; then
	echo "Instance name required." 1>&2
	exit 1
fi

if [ ! "${2}" = "" ]; then
	echo "Change file setting to ${2}"
	INSTANCE_CONF=${2}
fi


if [ ! -f "${INSTANCE_CONF}" ]; then
	echo "There is no instance config file."
	echo "${INSTANCE_CONF}"
	echo "Creating Instance with default settings."
else
	echo "Creating Instance with ${INSTANCE_CONF} settings."
	IFS=$'\n'
	INSTANCE_DATA=(`cat "$INSTANCE_CONF"`)
	for i in ${INSTANCE_DATA[@]}; do
		case "${i%%=*}" in
			"zone" )
				if [ "$i" = "zone" ];then
					continue
				fi
				INSTANCE_ZONE="${i#*=}"
				;;
			"machine-type" )
				if [ "$i" = "machine-type" ];then
					continue
				fi
				INSTANCE_MACHINE_TYPE="${i#*=}"
				;;
			"image-family" )
				if [ "$i" = "image-family" ];then
					continue
				fi
				INSTANCE_IMAGE_FAMILY="${i#*=}"
				;;
			"image-project" )
				if [ "$i" = "image-project" ];then
					continue
				fi
				INSTANCE_IMAGE_PROGECT="${i#*=}"
				;;
			"preemptible" )
				INSTANCE_PREEMPTIBLE="--preemptible"
				;;
		esac
	done
fi

echo ""
echo "Project Name:  ${PROJECT_NAME//\"}"
echo "Instance Name: ${INSTANCE_NAME//\"}"
echo "Zone:          ${INSTANCE_ZONE//\"}"
echo "Machine Type:  ${INSTANCE_MACHINE_TYPE//\"}"
echo "Image Family:  ${INSTANCE_IMAGE_FAMILY//\"}"
echo "Image Project: ${INSTANCE_IMAGE_PROJECT//\"}"
if [ "${INSTANCE_PREEMPTIBLE}" = "" ]; then
	echo 'Preemptible:   false'
else
	echo 'Preemptible:   true'
fi

gcloud compute --project "${PROJECT_NAME}" \
	instances create "${INSTANCE_NAME}" \
	--zone ${INSTANCE_ZONE//\"} \
	--machine-type ${INSTANCE_MACHINE_TYPE//\"} \
	--image-family ${INSTANCE_IMAGE_FAMILY//\"} \
	--image-project ${INSTANCE_IMAGE_PROJECT//\"} \
	--metadata-from-file startup-script="${SCRIPT_DIR}/gce_setup/instance_install.sh" \
	${INSTANCE_PREEMPTIBLE}

echo -e '\nDNS setup start.\n'

${SCRIPT_DIR}/dns_setup/dns_setup.sh


#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

CONF_FILE="${SCRIPT_DIR}/../conf.txt"

if [ ! -f "${CONF_FILE}" ]; then
	echo "There is no conf.txt file."
	exit 1
fi

. ${CONF_FILE}


dns_records=()

while read line; do
	dns_records+=("$line")
done << END
`gcloud dns record-sets list --zone=${DNS_ZONE}`
END

gcloud dns record-sets transaction start --zone ${DNS_ZONE}

for i in `seq 0 ${#dns_records[@]}`; do
	if [ $i -eq 0 -o $i -eq ${#dns_records[@]} ]; then
		continue
	fi

	set ${dns_records[${i}]}
	name=${1}
	type=${2}
	ttl=${3}
	data=${4}

	if [ ${type} != "A" ]; then
		continue
	fi

	#echo "[name]${name} [type]${type} [ttl]${ttl} [data]${data}"

	gcloud dns record-sets transaction remove --zone ${DNS_ZONE} \
		--name ${name} --ttl ${ttl} \
		--type ${type} "${data}"

done



instances=()

while read line; do
	instances+=("$line")
done << END
`gcloud compute instances list`
END

for i in `seq 0 ${#instances[@]}`; do
	if [ $i -eq 0 -o $i -eq ${#instances[@]} ]; then
		continue
	fi

	set ${instances[${i}]}
	name=${1}
	internal=${4}
	external=${5}
	status=${6}
	#echo "[name]${name} [internal]${internal} [external]${external} [status]${status}"

	if [[ ${status} != "RUNNING" ]]; then
		continue
	fi

	gcloud dns record-sets transaction add "${internal}" \
		--name ${name}.i.${DOMAIN} \
		--ttl ${TTL} --type A \
		--zone ${DNS_ZONE}
	gcloud dns record-sets transaction add "${external}" \
		--name ${name}.e.${DOMAIN} \
		--ttl ${TTL} --type A \
		--zone ${DNS_ZONE}

	gcloud dns record-sets transaction add "${internal}" \
		--name *.${name}.i.${DOMAIN} \
		--ttl ${TTL} --type A \
		--zone ${DNS_ZONE}
	gcloud dns record-sets transaction add "${external}" \
		--name *.${name}.e.${DOMAIN} \
		--ttl ${TTL} --type A \
		--zone ${DNS_ZONE}

done

gcloud dns record-sets transaction execute --zone ${DNS_ZONE}


gcloud dns record-sets list --zone=${DNS_ZONE}


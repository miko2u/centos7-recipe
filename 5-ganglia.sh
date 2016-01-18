#!/bin/bash
#
# 5. Ganglia
#
GANGLIA=${GANGLIA:-"127.0.0.1"}
CLUSTER_NAME=${CLUSTER_NAME:-"unspecified"}
CLUSTER_OWNER=${CLUSTER_OWNER:-"unspecified"}
CLUSTER_LOCATION=${CLUSTER_LOCATION:-"unspecified"}

# 5.1. ganglia
yum -y install ganglia ganglia-gmond ganglia-gmond-python
find / -xdev -group ganglia -exec chgrp 117 {} \;
find / -xdev -user ganglia -exec chown 117 {} \;
groupmod -g 117 ganglia
usermod -u 117 ganglia
etckeeper commit -m "SETUP ganglia"

# 5.2. ganglia-config
# NOTE: if enable reciever, "deaf = no"
sed	-e "s/send_metadata_interval = 0/send_metadata_interval = 15/g" \
	-e "s/name = \"unspecified\"/name = \"${CLUSTER_NAME}\"/g" \
	-e "s/owner = \"unspecified\"/owner = \"${CLUSTER_OWNER}\"/g" \
	-e "s/location = \"unspecified\"/location = \"${CLUSTER_LOCATION}\"/g" \
	-e 's/host_dmax = 0/host_dmax = 86400/g' \
	-e 's/deaf = no/deaf = yes/g' \
	-e '/mcast_join = 239.2.11.71/d' \
	-e '/ttl = 1/d' \
	-e '/bind = 239.2.11.71/d' \
	-i.dist /etc/ganglia/gmond.conf

sed	-e "/^udp_send_channel {/,/}/c udp_send_channel {\n  host = ${GANGLIA}\n  port = 8649\n}" \
	-i /etc/ganglia/gmond.conf
etckeeper commit -m "SETUP ganglia config"

# 5.X. ganglia-service
systemctl start gmond
systemctl enable gmond
etckeeper commit -m "SETUP ganglia service"

# vim:ts=4

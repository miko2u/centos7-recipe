#!/bin/bash
#
# 3-iptables
# NOTE: "iptables" instead of "firewalld". because conflict docker-1.10 and firewalld setting(s).
#
NAGIOS={$NAGIOS:-"127.0.0.1"}
ZABBIX={$ZABBIX:-"127.0.0.1"}
SSH_PORT={$SSH_PORT:-"22"}

# 3.1. uninstall firewalld
yum -y install iptables-services

# 3.3. ip6tables
cat << __EOT__ > /etc/sysconfig/ip6tables
# sample configuration for ip6tables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p ipv6-icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
-A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
COMMIT
__EOT__
chmod 600 /etc/sysconfig/ip6tables

# 3.4. iptables - basic
cat << __EOT__ > /etc/sysconfig/iptables
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:MONITOR - [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -i eth1 -j ACCEPT
-A INPUT -i eth2 -j ACCEPT
-A INPUT -s 172.17.0.0/16 -i docker0 -j ACCEPT
-A INPUT -s 172.18.0.0/16 -i docker_gwbridge -p tcp -m state --state NEW -m tcp --dport 25 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport ${SSH_PORT} -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 5666 -j MONITOR
-A INPUT -p tcp -m state --state NEW -m tcp --dport 10050 -j MONITOR
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
-A MONITOR -s ${NAGIOS} -j ACCEPT
-A MONITOR -s ${ZABBIX} -j ACCEPT
-A MONITOR -j REJECT --reject-with icmp-host-prohibited
COMMIT
__EOT__
chmod 600 /etc/sysconfig/iptables

# 3.X. restart and change enabled
systemctl stop firewalld
systemctl disable firewalld

systemctl enable iptables
systemctl start iptables

systemctl enable ip6tables
systemctl start ip6tables

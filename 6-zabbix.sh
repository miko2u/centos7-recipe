#!/bin/bash
#
# 6. zabbix
#
ZABBIX=${ZABBIX:-"127.0.0.1"}

# 6.1. zabbix
yum -y install http://repo.zabbix.com/zabbix/2.4/rhel/7/x86_64/zabbix-release-2.4-1.el7.noarch.rpm
yum -y reinstall zabbix-release
yum -y install zabbix-agent zabbix-get
find / -xdev -group zabbix -exec chgrp 116 {} \;
find / -xdev -user zabbix -exec chown 116 {} \;
groupmod -g 116 zabbix
usermod -u 116 zabbix
etckeeper commit -m "SETUP zabbix"

# 6.2. zabbix-config
sed -e "/^# EnableRemoteCommands.*$/a\EnableRemoteCommands=1" \
    -e "/^# LogRemoteCommands.*$/a\LogRemoteCommands=1" \
    -e "s/^Server=.*$/Server=${ZABBIX}/g" \
    -e "s/^ServerActive=.*$/ServerActive=${ZABBIX}/g" \
    -e "/^Hostname=.*$/d" \
    -e "/^# HostnameItem=.*$/a\HostnameItem=system.hostname" \
    -e "/^# HostMetadata=.*$/a\HostMetadata=Linux server" \
    -i.dist /etc/zabbix/zabbix_agentd.conf
etckeeper commit -m "SETUP zabbix config"

# 6.X. zabbix-service
systemctl start zabbix-agent
systemctl enable zabbix-agent
etckeeper commit -m "SETUP zabbix service"

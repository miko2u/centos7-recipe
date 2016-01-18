#!/bin/bash
#
# 2. environment
#

# 2.1. selinux disabled
sed -e "s/^SELINUX=.*$/SELINUX=disabled/" -i.dist /etc/selinux/config

# 2.2. enviroment
sed -e 's/LANG="C"/LANG="ja_JP.UTF-8"/' -i.dist /etc/sysconfig/i18n

# 2.3. logrotate
sed -e "s/^rotate 4/rotate 9/" \
    -e "s/^# keep 4/# keep 9/" \
    -e "s/^#compress/compress\ndelaycompress/" -i.dist /etc/logrotate.conf

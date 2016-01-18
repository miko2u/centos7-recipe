#!/bin/bash
#
# 2. environment
#

# 2.1. selinux disabled
sed -i.dist "s/^SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
etckeeper vcs diff | grep "^[+|-]"
etckeeper commit 'SETUP SELINUX disabled'

# 2.2. enviroment
localectl set-locale LANG=ja_JP.UTF-8
etckeeper vcs diff | grep "^[+|-]"
etckeeper commit 'SETUP LANG'

# 2.3. logrotate
sed -e "s/^rotate 4/rotate 9/" \
    -e "s/^# keep 4/# keep 9/" \
    -e "s/^#compress/compress\ndelaycompress/" \
    -i.dist /etc/logrotate.conf
etckeeper vcs diff | grep "^[+|-]"
etckeeper commit 'SETUP logrotate.conf'

# 2.4. chrony
yum -y install chrony
systemctl stop chronyd
find / -xdev -group chrony -exec chgrp 38 {} \;
find / -xdev -user chrony -exec chown 38 {} \;
groupmod -g 38 chrony
usermod -u 38 chrony
systemctl start chronyd
systemctl enable chronyd
chronyc sources
etckeeper commit 'SETUP chrony'

# 2.5. uidgid
systemctl stop polkit
find / -xdev -group polkitd -exec chgrp 987 {} \;
find / -xdev -user polkitd -exec chown 987 {} \;
groupmod -g 987 polkitd
usermod -u 987 polkitd

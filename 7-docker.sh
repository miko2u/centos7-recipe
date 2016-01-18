#!/bin/bash
#
# 7. docker
#

# 7.1. docker
yum -y install docker
find / -xdev -group cgred -exec chgrp 150 {} \;
find / -xdev -group docker -exec chgrp 151 {} \;
groupmod -g 150 cgred
groupmod -g 151 docker

# 7.2. docker-tools
curl -L https://github.com/docker/machine/releases/download/v0.5.6/docker-machine_linux-amd64 > /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-machine /usr/bin/docker-machine
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/fig

# 7.3. docker-config
systemctl start docker
systemctl enable docker

# 7.4. docker-cron
cat << '__EOT__' > /etc/sysconfig/docker-cron
# CRON_HOURLY=true
# CRON_DAILY=true
__EOT__

cat << '__EOT__' > /etc/cron.hourly/docker-cron
#!/bin/sh

CRON_HOURLY=true
[ -f /etc/sysconfig/docker-cron ] && source /etc/sysconfig/docker-cron

if [ $CRON_HOURLY == true ]; then
    for id in $(docker ps -q); do
        exec $(docker exec $id nice run-parts /etc/cron.hourly > /dev/null 2&>1)
    done
fi
exit 0
__EOT__

sed -e 's/HOURLY/DAILY/g' -e 's/hourly/daily/g' /etc/cron.hourly/docker-cron > /etc/cron.daily/docker-cron
chmod 644 /etc/sysconfig/docker-cron
chmod 755 /etc/cron.hourly/docker-cron /etc/cron.daily/docker-cron

# vim:ts=4

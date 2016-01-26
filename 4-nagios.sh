#!/bin/bash
#
# 4. Nagios
#
NAGIOS=${NAGIOS:-"127.0.0.1"}

# 4.1. nagios
yum -y install nagios-common
find / -xdev -group nagios -exec chgrp 119 {} \;
find / -xdev -user nagios -exec chown 119 {} \;
groupmod -g 119 nagios
usermod -u 119 nagios

# 4.2. nagios-agent
yum -y install nrpe
find / -xdev -group nrpe -exec chgrp 118 {} \;
find / -xdev -user nrpe -exec chown 118 {} \;
groupmod -g 118 nrpe
usermod -u 118 nrpe

# 4.3. nagios-plugins
yum -y install \
  nagios-plugins nagios-plugins-load nagios-plugins-users \
  nagios-plugins-http nagios-plugins-ping nagios-plugins-disk \
  nagios-plugins-ssh nagios-plugins-swap nagios-plugins-procs \
  nagios-plugins-nrpe nagios-plugins-smtp nagios-plugins-mysql \
  nagios-plugins-log nagios-plugins-ntp

# 4.4. nagios-nrpe
sed -e "s/^allowed_hosts=.*$/allowed_hosts=127.0.0.1,${NAGIOS}/" \
    -e "s/^dont_blame_nrpe=0$/dont_blame_nrpe=1/" \
    -e 's/^command\[check_users\]/#command[check_users]/' \
    -e 's/^command\[check_load\]/#command[check_load]/' \
    -e 's/^command\[check_hda1\]/#command[check_hda1]/' \
    -e 's/^command\[check_zombie_procs\]/#command[check_zombie_procs]/' \
    -e 's/^command\[check_total_procs\]/#command[check_total_procs]/' \
    -i.dist /etc/nagios/nrpe.cfg

cat << '__EOT__' > /etc/nrpe.d/default.cfg
# Plugins
command[check_users]=/usr/lib64/nagios/plugins/check_users -w $ARG1$ -c $ARG2$
command[check_load]=/usr/lib64/nagios/plugins/check_load -w $ARG1$ -c $ARG2$
command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w $ARG1$ -c $ARG2$ -W $ARG1$ -C $ARG2$ -p $ARG3$
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w $ARG1$ -c $ARG2$ -s $ARG3$
command[check_swap]=/usr/lib64/nagios/plugins/check_swap -w $ARG1$ -c $ARG2$
command[check_smtp]=/usr/lib64/nagios/plugins/check_smtp -w 5 -c 10
command[check_ntp]=/usr/lib64/nagios/plugins/check_ntp -H $ARG1$ -w 1 -c 2
command[check_mysql]=HOME=/var/lib/nrpe /usr/lib64/nagios/plugins/check_mysql -H localhost
# Process
command[check_proc]=/usr/lib64/nagios/plugins/check_procs -C $ARG4$ -w $ARG1$ -c $ARG2$ -s $ARG3$
command[check_nginx]=/usr/lib64/nagios/plugins/check_procs -C nginx -w $ARG1$ -c $ARG2$
command[check_httpd]=/usr/lib64/nagios/plugins/check_procs -C httpd -w $ARG1$ -c $ARG2$ -s $ARG3$
__EOT__

# 4.X. nagios-service
service nrpe start
chkconfig nrpe on

# vim:ts=4

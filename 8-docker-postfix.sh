#!/bin/bash
#
# 8. postfix
#
if [ ! -f /etc/postfix/main.cf.dist ]; then
    cp -pr /etc/postfix/main.cf /etc/postfix/main.cf.dist
fi

sed -e 's/^inet_interfaces = localhost$/inet_interfaces = localhost, 172.17.0.1, 172.18.0.1/g' \
    -e '/^#mynetworks_style = host/a\mynetworks_style = subnet/g' \
    -e '/^#mynetworks = hash/a\mynetworks = 127.0.0.0/8, 172.17.0.0/16, 172.18.0.0/16' \
    -i /etc/postfix/main.cf

# vim:ts=4

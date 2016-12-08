#!/bin/bash

export LOCAL_IP=$(hostname -I)
export HOSTIP=$(/sbin/ip route | awk '/default/ { print $3 }')
echo "${HOSTIP} container" >> /etc/hosts

supervisord
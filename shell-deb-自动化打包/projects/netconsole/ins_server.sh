#!/bin/bash
#
#####install
if ! dpkg -l |grep ' syslog-ng ' |grep -v grep >/dev/null ; then 
    apt-get install -y --force-yes syslog-ng 
fi
mkdir -p /var/log/netconsole_bakup /var/log/netconsole
mv /var/log/netconsole/*  /var/log/netconsole_bakup/
######config
cat <<EOF > /etc/syslog-ng/conf.d/01-netconsole.conf 
source net { udp(ip(0.0.0.0) port(6666)); };
destination netconsole { file(/var/log/netconsole/\$HOST-netconsole.log); };
log { source(net); destination(netconsole); };
EOF
#####reload
service syslog-ng restart


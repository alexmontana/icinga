#!/bin/sh

cd /usr/local/src
rm -rf /usr/local/src/*

yum -y update
yum -y install libdbi-devel libdbi httpd wget zip unzip

#wget -O icinga.tar.gz https://sourceforge.net/projects/icinga/files/icinga/1.10.1/icinga-1.10.1.tar.gz/download --no-check-certificate
# tar -xzf icinga.tar.gz
#cd icinga-1.10.1

wget -O icinga.zip https://codeload.github.com/Icinga/icinga2/zip/master
unzip icinga.zip
cd icinga2-master/

./configure --prefix=/opt/icinga --with-icinga-user=daemon --with-icinga-group=daemon --with-httpd-conf=/etc/httpd/conf 
 make all
 make install
 make install-config
 make install-commandmode
 make install-webconf

echo "Include conf/icinga.conf" >> /etc/httpd/conf/httpd.conf

htpasswd -nb icingaadmin icingaadmin > /opt/icinga/etc/htpasswd.users

/etc/init.d/httpd restart
killall -9 icinga; /opt/icinga/bin/icinga -d /opt/icinga/etc/icinga.cfg

wget https://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz#_ga=1.2791600.1279688733.1477871534 --no-check-certificate
tar -xzf nagios-plugins-2.1.2.tar.gz 
cd nagios-plugins-2.1.2
./configure --prefix=/opt/icinga/ --with-nagios-user=daemon --with-nagios-group=daemon
make
make install

/bin/cat << EndOfMessage >> /opt/icinga/etc/objects/commands.cfg
define command{
        command_name    run_logs_collector
        command_line    /home/logs_events.sh \$SERVICESTATE\$ \$SERVICESTATETYPE\$ \$SERVICEATTEMPT\$ \$HOSTADDRESS\$
        }
EndOfMessage

/opt/icinga/bin/icinga -v /opt/icinga/etc/icinga.cfg
killall -9 icinga; /opt/icinga/bin/icinga -d /opt/icinga/etc/icinga.cfg

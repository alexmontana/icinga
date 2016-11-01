#!/bin/bash

if [ ! -d /usr/local/src ]
  then
  mkdir -p /usr/local/src
fi

cd /usr/local/src

yum -y install mysql mysql-server httpd gcc* openssl-devel openssl xinetd

wget -O nrpe-2.15.tar.gz  https://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz/download --no-check-certificate
tar -xzf nrpe-2.15.tar.gz
cd nrpe-2.15
./configure --with-nagios-user=daemon --with-nagios-group=daemon --with-nrpe-group=daemon --with-nrpe-user=daemon
make all
make install-plugin
make install-daemon
make install-daemon-config
make install-xinetd


wget https://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz#_ga=1.2791600.1279688733.1477871534 --no-check-certificate
tar -xzf nagios-plugins-2.1.2.tar.gz 
cd nagios-plugins-2.1.2
./configure --with-nagios-user=daemon --with-nagios-group=daemon
make && make install
chown -R daemon:daemon /usr/local/nagios/


cat /dev/null > /etc/xinetd.d/nrpe
/bin/cat << EndOfMessage >> /etc/xinetd.d/nrpe
service nrpe
{
       	flags           = REUSE
        socket_type     = stream    
	port		= 5666    
       	wait            = no
        user            = daemon
	group		= daemon
       	server          = /usr/local/nagios/bin/nrpe
        server_args     = -c /usr/local/nagios/etc/nrpe.cfg --inetd
       	log_on_failure  += USERID
        disable         = no
	only_from       = 127.0.0.1 192.168.56.0/24
}
EndOfMessage

if [ "`grep 'nrpe 5666/tcp' /etc/services`" != "" ]
  then
  echo "Already there"
  else
  echo “nrpe 5666/tcp” >> /etc/services
fi


/etc/init.d/xinted restart

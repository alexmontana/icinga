#/bin/bash

TARGET_HOST=$1
TARGET_IP=$2

if [ "$TARGET_HOST" = "" ]
  then
  echo "ERROR: No host specified"
  echo "USAGE: cinga_add_host.sh HOSTNAME IP"
  exit 0;
fi

if [ "$TARGET_IP" = "" ]
  then
  echo "ERROR: No IP specified"
  echo "USAGE: cinga_add_host.sh HOSTNAME IP"
  exit 0;
fi

if [ ! -e /opt/icinga/etc/objects/"$TARGET_HOST".cfg ]
  then

/bin/cat << EndOfMessage >> /opt/icinga/etc/objects/"$TARGET_HOST".cfg
define host{
use linux-server
host_name $TARGET_HOST
alias $TARGET_HOST
address $TARGET_IP
}
define service{
use local-service
host_name $TARGET_HOST
service_description PING
check_command check_ping!100.0,20%!500.0,60%
}
define service{
use local-service
host_name $TARGET_HOST
service_description Root
check_command check_local_disk!20%!10%!/
}
define service{
use local-service
host_name $TARGET_HOST
service_description Current Users
check_command check_local_users!20!50
}
define service{
use local-service
host_name $TARGET_HOST
service_description Total Processes
check_command check_local_procs!250!400!RSZDT
}
define service{
use local-service
host_name $TARGET_HOST
service_description Current Load
check_command check_local_load!5.0,4.0,3.0!10.0,6.0,4.0
}
define service{
use local-service
host_name $TARGET_HOST
service_description Swap Usage
check_command check_local_swap!20!10
}
define service{
use local-service
host_name $TARGET_HOST
service_description SSH
check_command check_ssh
notifications_enabled 0
}
define service{
use local-service
host_name $TARGET_HOST
service_description MYSQL
check_command check_tcp!3306
notifications_enabled 0
event_handler run_logs_collector
}
define service{
use local-service
host_name $TARGET_HOST
service_description HTTP
check_command check_tcp!80
notifications_enabled 0
event_handler run_logs_collector
}
EndOfMessage

cp -rp /opt/icinga/etc/icinga.cfg /opt/icinga/etc/icinga.cfg_bak_$(date +%Y-%m-%d_%H-%M-%S)
echo "cfg_file=/opt/icinga/etc/objects/$TARGET_HOST.cfg" >> /opt/icinga/etc/icinga.cfg
/opt/icinga/bin/icinga -v /opt/icinga/etc/icinga.cfg
killall -9 icinga; /opt/icinga/bin/icinga -d /opt/icinga/etc/icinga.cfg

else

   echo "ERROR: Hostname $TARGET_HOST is already configured"
   exit 0;
fi

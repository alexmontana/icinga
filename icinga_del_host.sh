#/bin/bash

TARGET_HOST=$1

if [ "$TARGET_HOST" = "" ]
  then
  echo "ERROR: No host specified"
  echo "USAGE: cinga_del_host.sh HOSTNAME"
  exit 0;
fi

if [ -e /opt/icinga/etc/objects/"$TARGET_HOST".cfg ]
  then

  cp -rp /opt/icinga/etc/icinga.cfg /opt/icinga/etc/icinga.cfg_bak_$(date +%Y-%m-%d_%H-%M-%S)
  sed -i "/$TARGET_HOST.cfg/d" /opt/icinga/etc/icinga.cfg
  rm -f /opt/icinga/etc/objects/"$TARGET_HOST".cfg

  /opt/icinga/bin/icinga -v /opt/icinga/etc/icinga.cfg
  killall -9 icinga; /opt/icinga/bin/icinga -d /opt/icinga/etc/icinga.cfg

   else

   echo "ERROR: Hostname $TARGET_HOST is not found"
   exit 0;
fi

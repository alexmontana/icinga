#!/bin/bash

# this script is to take mysql.log and Apache access_log
# files from remote server TARGET_HOST and put them
# into WORKING_DIR
# NOTE: ensure SSH keys pair is configured between 
# current server and TARGET_HOST to avoid password prompt
# --
# designed by Alex Morozov



# some constants ===

TARGET_HOST=192.168.56.102
WORKING_DIR="/home/logs"

CURR_DATE=`date +%Y-%m-%d_%H-%M-%S`

# =================

if [ ! -d $WORKING_DIR  ]
  then
  mkdir -p $WORKING_DIR
fi

cd $WORKING_DIR

# copying files from TARGET_HOST and TAR.GZ them ===

scp -rp root@$TARGET_HOST:/var/log/mysqld.log ./"$CURR_DATE"_mysqld.log
scp -rp root@$TARGET_HOST:/var/log/httpd/access_log ./"$CURR_DATE"_access_log

if [ -e "$CURR_DATE"_mysqld.log ]
  then
  tar -czf "$CURR_DATE"_mysqld.log.tar.gz "$CURR_DATE"_mysqld.log
fi

if [ -e "$CURR_DATE"_access_log ]
  then
  tar -czf "$CURR_DATE"_access_log.tar.gz "$CURR_DATE"_access_log
fi
# ==================================================

#!/bin/bash

# this script is to upload TAR.GZ files located in WORKING_DIR
# into S3 Bucket
# --
# designed by Alex Morozov



# some constants ===

WORKING_DIR="/home/logs"
CURR_DATE=`date +%Y-%m-%d`


# my personal S3 variables

S3KEY="AKIAIT7HRMG3EDVM2SSQ"
S3SECRET="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"
bucket="alex-morozov-1"


# =================

if [ ! -d $WORKING_DIR  ]
  then
  mkdir -p $WORKING_DIR
  chmod 777 $WORKING_DIR
fi

cd $WORKING_DIR

# making a single archive file as an additiomal backup ===

tar -czf single_file_backup_"$CURR_DATE".tar.gz *mysqld.log *access_log

# ========================================================

for i in $(ls | grep tar.gz | grep -E 'mysqld.log|access_log|single_file_backup')
  do

  # date=$(date +"%a, %d %b %Y %T %Z")
  date="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"
  acl="x-amz-acl:public-read"
  content_type='application/x-compressed-tar'
  string="PUT\n\n$content_type\n$date\n$acl\n/$bucket/$i"
  signature=$(echo -en "${string}" | openssl sha1 -hmac "${S3SECRET}" -binary | base64)
  curl -X PUT -T "$i" \
    -H "Host: $bucket.s3.amazonaws.com" \
    -H "Date: $date" \
    -H "Content-Type: $content_type" \
    -H "$acl" \
    -H "Authorization: AWS ${S3KEY}:$signature" \
    "https://$bucket.s3.amazonaws.com/$i"

  done

# cleaning up old logs/TAR.GZ files ===

rm -f $WORKING_DIR/*.tar.gz
rm -f $WORKING_DIR/*log

# =====================================

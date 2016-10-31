#!/bin/bash

case "$1" in
OK)
        ;;
WARNING)  
        ;;
UNKNOWN)  
        ;;
CRITICAL) 
        # Is this a "soft" or a "hard" state?
        case "$2" in
        SOFT)
                case "$3" in
                
                3)
                        echo -n "Restarting HTTP service (3rd soft critical state)..."
                        # Call the init script to restart the HTTPD server
                        ssh root@"$4" /etc/rc.d/init.d/httpd restart
                        ssh root@"$4" /etc/init.d/mysqld restart
                        /home/logs_collector.sh
                        ;;
                        esac
                ;;
                  
        HARD)
                echo -n "Restarting HTTP service..."
                # Call the init script to restart the HTTPD server
                ssh root@"$4"  /etc/rc.d/init.d/httpd restart
                ssh root@"$4" /etc/init.d/mysqld restart
                /home/logs_collector.sh
                ;;
        esac
        ;;  
esac
exit 0

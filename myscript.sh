#!/bin/bash

function IsChange {
sed -i "s/^SELINUX=.*/SELINUX=$1/g" /etc/selinux/config
echo "----------------------------------------------"
sestatus
echo "----------------------------------------------"
echo "Mode from config file: $1"
echo "If Disabled or Enforcing - must reboot after changing."
}

if ! [ $(id -u) = 0 ]; then
    echo "Run the script as ROOT (or sudo)"
exit 1
else
    clear
    sestatus
    echo "----------------------------------------------"
    SELINUXSTATUS=$(getenforce)
    case $SELINUXSTATUS in
        Enforcing )
          echo "Selinux is enforcing. Print 1 - disabled, 2 - permissive:"
      read disable
       case $disable in
         1)
         setenforce 0
         IsChange disabled
         ;;
         2)
         setenforce 0
         IsChange permissive
         ;;
         esac
    ;;
        Permissive )
      echo "Selinux is permissive. Print 1 - disabled, 2 - enforcing:"
      read disable
      case $disable in
         1)
         setenforce 0
         IsChange disabled
         ;;
         2)
         setenforce 1
         IsChange enforcing
         ;;
         esac
    ;;
        Disabled )
          echo "Selinux is disabled. Print 1 - enforsing, 2 - permissive:"
      read disable
       case $disable in
         1)
         IsChange enforcing
         setenforce 1
         ;;
         2)
         IsChange permissive
         setenforce 0
         ;;
         esac
        ;;
    esac

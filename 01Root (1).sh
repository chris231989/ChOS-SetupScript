#!/bin/bash

#01Makecontainer

echo "Test Rooting scripts for Android on Chrome OS"
sleep 1
echo
echo
echo "Version 0.21"
sleep 1
echo
echo "Unofficial scripts to copy SuperSU files to an Android system image on Chrome OS"
sleep 1
echo
echo "Part 1 of 2"
sleep 1
echo
echo "INTEL VERSION - UNVERIFIED"
sleep 1
echo
echo "This script is for Intel Chromebooks only!"
echo
echo "This script expects the x86 and common folders from the SuperSU zip to be extracted to separate folders in Downloads."
sleep 1
echo
echo "In order to modify system files, the Chrome OS system partition needs to have been mounted writeable"
echo "A straightforward way to enable this is with the following command:"
echo
echo
echo
echo
echo "sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --force --partitions $(( $(rootdev -s | sed -r 's/.*(.)$/\1/') - 1))"
sleep 1
echo
echo
echo "Alternatively, run the command below, then follow the prompt."
echo
echo
echo "sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification"
sleep 1
echo
echo
echo
echo
echo "Press Ctrl+C to cancel if you still need to do the above."
sleep 6
echo
echo "Be aware that modifying the system partition could cause automatic updates to fail, may result in having to powerwash or restore from USB potentially causing loss of data! Please make sure important files are backed up."
echo
echo

#Check if filesystem has been mounted R/W

touch "/.this"  2> /dev/null

if [ ! -e /.this ]; then
  echo
  echo "Error!"
  echo "Unable to modify system!"
  echo
  echo "Please retry the "remove_rootfs_verification" command above. (then reboot)"
  exit 1
fi

rm /.this

#Check if symlink already exists

if [ -L /opt/google/containers/android/system.raw.img ]; then
  echo "The file at /opt/google/containers/android/system.raw.img is already a symlink!"

#check if backup exists

  if [ ! -f /home/chronos/user/Downloads/system.raw.img ]; then
  
    if [ ! -f /opt/google/containers/android/system.raw.img.bk ]; then
      echo
      echo "Error!"
      echo "System.raw.img not found"
      echo
      exit 1
    fi
    
  fi
  
  echo "Removing symlink"
  rm -rf /opt/google/containers/android/system.raw.img
fi
  
if [ ! -e /opt/google/containers/android/system.raw.img ]; then

  if [ -f /opt/google/containers/android/system.raw.img.bk ]; then
    echo "Using /opt/google/containers/android/system.raw.img.bk"
  else

    if [ -f /home/chronos/user/Downloads/system.raw.img ]; then
      echo "Using /home/chronos/user/Downloads/system.raw.img"
    else
      echo
      echo "Error!"
      echo "System.raw.img not found"
      echo
      exit 1
    fi
    
  fi
  
fi

#Unmount any previous instances

umount -l /usr/local/Android_Images/system.raw.expanded.img 2>/dev/null
umount -l /usr/local/Android_Images/system.raw.expanded.img 2>/dev/null
umount -l /usr/local/Android_Images/Mounted 2>/dev/null
umount -l /usr/local/Android_Images/Original 2>/dev/null

#Remount the Chrome OS root drive as writeable

mount -o remount,rw /

#Create some working directories if they don't already exist

cd /usr/local/

  mkdir -p /usr/local/Android_Images
  mkdir -p /usr/local/Android_Images/Mounted
  mkdir -p /usr/local/Android_Images/Original

#Create a blank image. Size needs to be at least ~1.4GB
#(~1GB for Marshmallow)

echo "Creating new Android system image at /usr/local/Android_Images/system.raw.expanded.img"
echo
echo
    
cd /usr/local/Android_Images && dd if=/dev/zero of=system.raw.expanded.img count=1424000 bs=1024 status=progress
  
echo
echo "Formatting system.raw.expanded.img as ext4 filesystem"
echo

  mkfs ext4 -F /usr/local/Android_Images/system.raw.expanded.img

echo "Mounting system.raw.expanded.img"

if [ -e /opt/google/containers/android/system.raw.img ]; then

  if [ -L /opt/google/containers/android/system.raw.img ]; then
  
    if [ -e /opt/google/containers/android/system.raw.img.bk ]; then
      umount -l /usr/local/Android_Images/Original 2>/dev/null
      mount -o loop,rw,sync /opt/google/containers/android/system.raw.img.bk /usr/local/Android_Images/Original 2>/dev/null
    else
        
      if [ -e /home/chronos/user/Downloads/system.raw.img ]; then
        umount -l /usr/local/Android_Images/Original 2>/dev/null
        mount -o loop,rw,sync /home/chronos/user/Downloads/system.raw.img /usr/local/Android_Images/Original 2>/dev/null
      else
        echo
        echo "Error!"
        echo "System.raw.img not found"
        echo
        exit 1
      fi
    
    fi
      
  fi
    
fi

if [ ! -L /opt/google/containers/android/system.raw.img ]; then
   
  if [ -e /opt/google/containers/android/system.raw.img ]; then
    umount -l /usr/local/Android_Images/Original 2>/dev/null
    mount -o loop,rw,sync /opt/google/containers/android/system.raw.img /usr/local/Android_Images/Original 2>/dev/null
  else
  
    if [ -e /opt/google/containers/android/system.raw.img.bk ]; then
      umount -l /usr/local/Android_Images/Original 2>/dev/null
      mount -o loop,rw,sync /opt/google/containers/android/system.raw.img.bk /usr/local/Android_Images/Original 2>/dev/null
    else
    
      if [ -e /home/chronos/user/Downloads/system.raw.img ]; then
        echo "Mounting /home/chronos/user/Downloads/system.raw.img and copying files"
        umount -l /usr/local/Android_Images/Original 2>/dev/null
        mount -o loop,rw,sync /home/chronos/user/Downloads/system.raw.img /usr/local/Android_Images/Original 2>/dev/null
      else
        echo
        echo "Error!"
        echo "System.raw.img not found"
        echo
        exit 1
      fi

    fi

  fi
  
fi
        #ORIGINAL_ANDROID_ROOTFS=/opt/google/containers/android/rootfs/root
        ANDROID_ROOTFS=/usr/local/Android_Images/Original

#Try to set SELinux to 'Permissive'.At one point, the ability to 'setenforce' was removed in an OS update. (it was later restored in another update).

setenforce 0

#Check if it worked

SE=$(getenforce)
if SE="Permissive"
then

echo "SELinux successfully set to 'Permissive' temporarily"

echo "Copying Android system files"

mount -o loop,rw,sync /usr/local/Android_Images/system.raw.expanded.img /usr/local/Android_Images/Mounted

cp -a -r $ANDROID_ROOTFS/. /usr/local/Android_Images/Mounted

else

#Workaround to copy files with correct contexts in Enforcing mode

echo "Copying Android system files"

    #Directories mounted with special contexts:
    
          #u:object_r:cgroup:s0 acct
          #u:object_r:device:s0 dev
          #u:object_r:tmpfs:s0 mnt
          #u:object_r:oemfs:s0 oem
          #u:object_r:sysfs:s0 sys

mount -o loop,rw,sync,fscontext=u:object_r:cgroup:s0 /usr/local/Android_Images/system.raw.expanded.img /usr/local/Android_Images/Mounted

cp -a -r $ANDROID_ROOTFS/acct /usr/local/Android_Images/Mounted/acct

umount -l /usr/local/Android_Images/Mounted

mount -o loop,rw,sync,fscontext=u:object_r:device:s0 /usr/local/Android_Images/system.raw.expanded.img /usr/local/Android_Images/Mounted

cp -a -r $ANDROID_ROOTFS/dev /usr/local/Android_Images/Mounted/dev

umount -l /usr/local/Android_Images/Mounted

mount -o loop,rw,sync,fscontext=u:object_r:tmpfs:s0 system.raw.expanded.img /usr/local/Android_Images/Mounted

cp -a -r $ANDROID_ROOTFS/mnt /usr/local/Android_Images/Mounted/mnt

umount -l /usr/local/Android_Images/Mounted

mount -o loop,rw,sync,fscontext=u:object_r:oemfs:s0 /usr/local/Android_Images/system.raw.expanded.img /usr/local/Android_Images/Mounted

cp -a -r $ANDROID_ROOTFS/oem /usr/local/Android_Images/Mounted/oem

umount -l /usr/local/Android_Images/Mounted

mount -o loop,rw,sync,fscontext=u:object_r:sysfs:s0 /usr/local/Android_Images/system.raw.expanded.img /usr/local/Android_Images/Mounted

cp -a -r $ANDROID_ROOTFS/sys /usr/local/Android_Images/Mounted/sys

umount -l /usr/local/Android_Images/Mounted

mount -o loop,rw,sync /usr/local/Android_Images/system.raw.expanded.img /usr/local/Android_Images/Mounted

cp -a -r $ANDROID_ROOTFS/storage /usr/local/Android_Images/Mounted/storage

umount -l /usr/local/Android_Images/Mounted

#Copying rootfs files

mount -o loop,rw,sync,fscontext=u:object_r:rootfs:s0 /usr/local/Android_Images/system.raw.expanded.img /usr/local/Android_Images/Mounted

cp -a -r $ANDROID_ROOTFS/. /usr/local/Android_Images/Mounted

fi

if [  -f /opt/google/containers/android/system.raw.img ]; then
  umount -l /opt/google/containers/android/system.raw.img  > /dev/null 2>&1 || /bin/true
fi

#This backup seems unnecessary now, since we already have the original file 'mv'ed to *.bk in place
#and it takes up too much space, especially since the Nougat filesize increase.

#if [ -e /opt/google/containers/android/system.raw.img ]; then
  
#  if [ ! -L /opt/google/containers/android/system.raw.img ]; then
#    echo "Copying original rootfs image to /home/chronos/user/Downloads/system.raw.img as a backup."
#    cp -a /opt/google/containers/android/system.raw.img /home/chronos/user/Downloads/system.raw.img
#  fi
 
#fi

if [ -e /opt/google/containers/android/system.raw.img ]; then

  if [ ! -L /opt/google/containers/android/system.raw.img ]; then
    echo "Moving original rootfs image to /opt/google/containers/android/system.raw.img.bk"
    mv /opt/google/containers/android/system.raw.img  /opt/google/containers/android/system.raw.img.bk
    echo "Creating symlink to /usr/local/Android_Images/system.raw.expanded.img"
    ln  -s /usr/local/Android_Images/system.raw.expanded.img /opt/google/containers/android/system.raw.img
  fi
  
  else
  
  if [ -e /usr/local/Android_Images/system.raw.expanded.img ]; then
    echo "Creating symlink to /usr/local/Android_Images/system.raw.expanded.img"
    ln  -s /usr/local/Android_Images/system.raw.expanded.img /opt/google/containers/android/system.raw.img
  fi
  
fi

mkdir -p /usr/local/Backup

if [ -e /etc/init/arc-setup-env ]; then
  echo "Copying /etc/init/arc-setup-env to /usr/local/Backup"
  
  sleep 1

  echo "Setting 'export WRITABLE_MOUNT=1' and 'export ANDROID_DEBUGGABLE=1' in /etc/init/arc-setup-env"
  
  sed -i 's/export WRITABLE_MOUNT=0/export WRITABLE_MOUNT=1/g' /etc/init/arc-setup-env
  sed -i 's/export ANDROID_DEBUGGABLE=0/export ANDROID_DEBUGGABLE=1/g' /etc/init/arc-setup-env

else
  
  echo "Copying /etc/init/arc-setup.conf and /etc/init/arc-system-mount.conf to /usr/local/Backup"

  sleep 1

  echo "Setting 'env WRITABLE_MOUNT=1' in /etc/init/arc-setup.conf and /etc/init/arc-system-mount.conf"

  cp -a /etc/init/arc-system-mount.conf /usr/local/Backup/arc-system-mount.conf.old
  cp -a /etc/init/arc-system-mount.conf /etc/init/arc-system-mount.conf.old
  
  cp -a /etc/init/arc-setup.conf /usr/local/Backup/arc-setup.conf.old
  cp -a /etc/init/arc-setup.conf /etc/init/arc-setup.conf.old
  
  sed -i 's/env WRITABLE_MOUNT=0/env WRITABLE_MOUNT=1/g' /etc/init/arc-setup.conf
  sed -i 's/env WRITABLE_MOUNT=0/env WRITABLE_MOUNT=1/g' /etc/init/arc-system-mount.conf

  echo "Setting 'env ANDROID_DEBUGGABLE=1' in arc-setup.conf"

  sed -i 's/env ANDROID_DEBUGGABLE=0/env ANDROID_DEBUGGABLE=1/g' /etc/init/arc-setup.conf
fi

echo
echo "Make sure the x86 and common folders from the SuperSU zip have been extracted to 'Downloads'"

sleep 1

umount -l /usr/local/Android_Images/system.raw.expanded.img 2>/dev/null
  
cd /usr/local/Android_Images
mkdir -p /usr/local/Android_Images/Mounted

mount -o loop,rw,sync /usr/local/Android_Images/system.raw.expanded.img /usr/local/Android_Images/Mounted 2>/dev/null

          ARCH=/home/chronos/user/Downloads/x86
          common=/home/chronos/user/Downloads/common
          system=/usr/local/Android_Images/Mounted/system
          #system_original=/opt/google/containers/android/rootfs/root/system
echo
echo "Now placing SuperSU files. Locations as indicated by the SuperSU update-binary script."

sleep 1

echo

#Copying SuperSU files to $system
    
echo "Creating SuperSU directory in system/app/, copying SuperSU apk, and setting its permissions and contexts"

cd $system/app
  mkdir $system/app/SuperSU
  
cd $system/app/SuperSU
  cp $common/Superuser.apk $system/app/SuperSU/SuperSU.apk

  chmod 0644 $system/app/SuperSU/SuperSU.apk
  chcon u:object_r:system_file:s0 $system/app/SuperSU/SuperSU.apk

sleep 1

echo "Copying su binaries to system/xbin/ and setting permissions and contexts"

cd $system/xbin

  cp $ARCH/su.pie $system/xbin/su
  cp $ARCH/su.pie $system/xbin/daemonsu
  cp $ARCH/su.pie $system/xbin/sugote

  chmod 0755 $system/xbin/su
  chmod 0755 $system/xbin/daemonsu
  chmod 0755 $system/xbin/sugote

  chcon u:object_r:system_file:s0 $system/xbin/su
  chcon u:object_r:system_file:s0 $system/xbin/daemonsu
  chcon u:object_r:zygote_exec:s0 $system/xbin/sugote

sleep 1

echo "Creating directory system/bin/.ext/.su"

cd $system/bin

  mkdir $system/bin/.ext

echo "Copying su to system/bin/.ext/.su and setting permissions and contexts"

cd $system/bin/.ext

  cp $ARCH/su.pie $system/bin/.ext/.su
  chmod 0755 $system/bin/.ext/.su
  chcon u:object_r:system_file:s0 $system/bin/.ext/.su
  
sleep 1

echo "Copying supolicy to system/xbin, libsupol to system/lib and setting permissions and contexts"

cd $system/xbin

  cp $ARCH/supolicy $system/xbin/supolicy

  chmod 0755 $system/xbin/supolicy
  chcon u:object_r:system_file:s0 $system/xbin/supolicy

cd $system/lib

  cp $ARCH/libsupol.so $system/lib/libsupol.so

  chmod 0644 $system/lib/libsupol.so
  chcon u:object_r:system_file:s0 $system/lib/libsupol.so
  
sleep 1

echo "Copying sh from system/bin/sh to system/xbin/sugote-mksh and setting permissions and contexts"

cd $system/bin

  cp $system/bin/sh ../xbin/sugote-mksh

cd $system/xbin

  chmod 0755 $system/xbin/sugote-mksh
  chcon u:object_r:system_file:s0 $system/xbin/sugote-mksh
  
#Hijacking app_process worked on Marshmallow. Does not work on N.
#Nougat test: modifying init.*.rc instead.
  
#echo "Moving app_process32"

#cd $system/bin/

#  cp app_process32 $system/bin/app_process32_original
#  chmod 0755 $system/bin/app_process32_original
#  chcon u:object_r:zygote_exec:s0 $system/bin/app_process32_original

#  cp $system/bin/app_process32 $system/bin/app_process_init

#chmod 0755 $system/bin/app_process_init
#chcon u:object_r:system_file:s0 $system/bin/app_process_init

#sleep 1

#echo "Deleting original app_process, app_process32"

#  rm $system/bin/app_process
#  rm $system/bin/app_process32

#sleep 1

#echo "Symlinking app_process, app_process32 to system/xbin/daemonsu"

#cd $system/xbin

#  ln -s -r daemonsu ../bin/app_process
#  ln -s -r daemonsu ../bin/app_process32

#sleep 1

echo "Adding extra files system/etc/.installed_su_daemon and system/etc/install-recovery.sh"

cd $system/etc

  touch  $system/etc/.installed_su_daemon

  chmod 0644  $system/etc/.installed_su_daemon
  chcon u:object_r:system_file:s0  $system/etc/.installed_su_daemon

  cp $common/install-recovery.sh  $system/etc/install-recovery.sh
  
  chmod 0755  $system/etc/install-recovery.sh
  chcon u:object_r:toolbox_exec:s0  $system/etc/install-recovery.sh
  
echo "Symlinking system/bin/install-recovery.sh to system/etc/install-recovery.sh"

  ln -s -r install-recovery.sh ../bin/install-recovery.sh
  
#SuperSU copying script ends

echo "Adding system/bin/daemonsu-service.sh"

 cp $common/install-recovery.sh  $system/bin/daemonsu-service.sh
  
  chmod 0755  $system/bin/daemonsu-service.sh
  chown 655360 $system/bin/daemonsu-service.sh
  chgrp 657360 $system/bin/daemonsu-service.sh
  chcon u:object_r:toolbox_exec:s0  $system/bin/daemonsu-service.sh

echo "Creating file init.super.rc in Android rootfs"

touch  $system/../init.super.rc

chmod 0750 $system/../init.super.rc
chown 655360 $system/../init.super.rc
chgrp 657360 $system/../init.super.rc

echo "Adding daemonsu service to init.super.rc"

echo "service daemonsu /system/bin/daemonsu-service.sh service
    class late_start
    user root
    seclabel u:r:supersu:s0
    oneshot" >>  $system/../init.super.rc
    
echo "Adding 'import /init.super.rc' to existing init.rc"

sed -i '7iimport /init.super.rc' $system/../init.rc

echo
echo
echo "Done!"
echo
echo "Please check the output of this script for any errors."

sleep 1

echo
echo "Please reboot now, then run script 02SEPatch.sh."

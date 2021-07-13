#!/bin/bash
# unregister current server from systemctl
# close firewall ports
# keep the files
# -- instance.cfg


echo "uninstall server from pwd or from instance.cfg???"

exit 1

mcsWorkDir=$(pwd -P)
echo "Uninstall will remove the system service and close firewall ports"
echo "for the minecraft server in this directory. No files will be deleted here."
echo "You can later remove the current directory manually."
echo "Consider to backup the minecraft world first: World directories are:"
echo " world, world_the_end and world_nether."
echo "Current directory: $mcsWorkDir"
echo -n "Shall we proceed? (y/n)?"
read ans
if [ "$ans" != "${ans#[Yy]}" ]; then
  echo "Ok, the server will be unregistered."
else
  echo "Aborted, will exit now."
  exit 1
fi

if [ -e "instance.cfg" ]; then
  source instance.cfg
else
  echo "Server setup file instance.cfg not found. Cannot proceed.. Exit."
  exit 1
fi

if [ "$mcsInstanceActive" != "true" ]; then
  echo -n "Server instance is not active - probably nothing to do. Try anyway? (y/n)"
  read ans
  if [ "$ans" != "${ans#[Yy]}" ]; then
    exit 1
  fi
fi

if [ "`pwd -P`" != "$mcsWorkDir" ]
  echo "Server working directory does not match the current script directory."
  echo "The script may have been copied to another location or directories have been renamed."
  echo "This script will uninstall the server running in the directory, which is set"
  echo "in the instance.cfg file. Attention! You may unintentially uninstall the wrong server."
  echo -n " Continue anyway? (y/n)"
  read ans
  if [ "$ans" != "${ans#[Yy]}" ]; then
    exit 1
  fi
fi

# will not change mcsWorkDir - install.sh will.
# mcsInstanceActive - will set false after finishing.
# will not change anything else.

echo "1. Stop the server if running.."
bash stop.sh

echo "2. Remove system service.."
sudo systemctl daemon-reload
echo "  Disable the instance system service"
sudo systemctl disable "$mcsInstance".service
echo "  Delete the service definition file"
sudo rm /etc/systemd/system/"$mcsInstance".service


echo "Remove instance ports from firewall..."
sudo firewall-cmd --remove-port=$mcsInstancePort/tcp
sudo firewall-cmd --remove-port=$mcsInstancePort/udp
sudo firewall-cmd --reload



echo "remove daily backup task from crontab"
croncmd="$mcsWorkDir/backup.sh"
cronjob="15 4 * * * $croncmd"
# this should just remove croncmd:
( crontab -l | grep -v -F "$croncmd" ) | crontab -


echo "Done.. Setting instance configuration inactive." 

mcsInstanceActive=false
sed -i "s/mcsInstanceActive=.*/mcsInstanceActive=$mcsInstanceActive/g" instance.cfg


# References






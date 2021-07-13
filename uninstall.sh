#!/bin/bash
# unregister current server from systemctl
# close firewall ports
# keep the files
# -- instance.cfg


if [ -e "instance.cfg" ]; then
  source instance.cfg
else
  echo "Server setup file instance.cfg not found. Cannot proceed, sorry.."
  exit 1
fi

echo "Uninstall will remove the system service and close firewall ports"
echo "for the minecraft server specified in instance.cfg."
echo "No files will be deleted in current or the instance directory."
echo "You would need to remove the directory manually."
echo "Consider to backup the minecraft world first."
echo "World directories are: 'world', 'world_the_end' and 'world_nether'."

currDir=$(pwd -P)
if ["$currDir" != "$mcsWorkDir"]; then # eventually different folders
  echo "Warning: it seems as if we were in a differend folder"
  echo " than specified in the instance.cfg!"
  echo "  We are in: $currDir"
  echo "  Instance working directory is $mcsWorkDir"
  echo "The script will use information from instance.cfg"
  echo "Be careful - you might uninstall a wrong server ;)"
fi

echo -n "Shall we proceed? (y/n)?"
read ans
if [ "$ans" != "${ans#[Yy]}" ]; then
  echo "Ok, the server will be unregistered."
else
  echo "Aborted, will exit now."
  exit 1
fi


if [ "$mcsInstanceActive" != "true" ]; then
  echo -n "Server instance is not marked to be active. Continue anyway? (y/n)"
  read ans
  if [ "$ans" != "${ans#[Yy]}" ]; then
    exit 1
  fi
fi


# after uninstall:
#  will not change mcsWorkDir - install.sh will.
#  mcsInstanceActive - will set false after finishing.
#  will not change anything else.

echo "1. Stop the server if running.."
bash stop.sh
echo "2. Remove system service."
sudo systemctl daemon-reload
echo "  Disable the instance system service"
sudo systemctl disable "$mcsInstance".service
echo "  Delete the service definition file"
sudo rm /etc/systemd/system/"$mcsInstance".service
echo "Remove instance ports from firewall..."
sudo firewall-cmd --remove-port="$mcsInstancePort"/tcp
sudo firewall-cmd --remove-port="$mcsInstancePort"/udp
sudo firewall-cmd --reload
echo "remove daily backup task from crontab"
croncmd="$mcsWorkDir/backup.sh"
# this should just remove croncmd:
( crontab -l | grep -v -F "$croncmd" ) | crontab -

echo "Done.. Setting instance configuration inactive." 
mcsInstanceActive=false
sed -i "s/mcsInstanceActive=.*/mcsInstanceActive=$mcsInstanceActive/g" instance.cfg


# References






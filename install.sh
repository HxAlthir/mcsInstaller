#!/bin/bash
# Creates a new instance of the minecraft server
# 
# Preparation steps to be done manually:
# 1. Create a new folder in (for example) /opt/minecraft : e.g. "mc1" (with sudo)
# 2. Change owner of the folder to the "normal" user:
#       sudo chown user:users mc1
# 3. Download the script files to the new folder
# 4. optional: edit instance.cfg
# 5. run install.sh


# -- other files --
# start.sh      :   start server instance
# stop.sh       :   stop server instance
# config.sh     :   change some server preferences
# backup.sh     :   create a backup (stop/start server if requiered)
# uninstall.sh  :   undo system service registration an close firewall ports
# instance.cfg  :   Configuration file for essential parameters like port and server tag
# update.sh     :   update paperMC


# Make sure we aren't root
if [ $(id -u) = 0 ]; then
   echo "Dont run this script as root or sudo. Run normally with ./install.sh."
   exit 1
fi


# check installation status
if [ -e "instance.cfg" ]; then
  source instance.cfg
  if [ "$mcsInstanceActive" != "false" ]; then
    echo "The instance seems to be installed already! Will exit now."
    echo "Run uninstall first if you want to change essential settings like port or instance name."
    echo "If the scripts have been copied from another (active) instance folder then you need"
    echo "to edit the instance.cfg file, and change at least the parameters:"
    echo " mcsInstance and mcsInstancePort."
    echo "Then set mcsInstanceActive=false and run install.sh again."
    exit 1
  # else
    # Instance is inactive, config loaded.
  fi
else
  echo "instance.cfg not found! Check the installation! Will exit now :(" 
  exit 1
fi




# working directory:
# resolve symlinks
mcsWorkDir=$(pwd -P)
echo -n "Install and register a new minecraft server in the directory $mcsWorkDir (y/n)?"
read ans
if [ "$ans" != "${ans#[Yy]}" ]; then
  echo "ok, lets go!"
else
  echo "Aborted, will exit now."
  exit 1
fi

# Check if Java is available
if [ -n "$(which java)" ]; then
  echo "Java is present."
else
  echo -n "Java not found! Run Java installer?(y/n)?"
  read ans
  if [ "$ans" != "${ans#[Yy]}" ]; then
    echo "not yet implemented"
    ## toDo : Java Installer : call script
    # - install and doublecheck status
    exit 1
  else
    echo "Ok, try to install Java manually! Will exit now."
    exit 1
  fi
fi



echo "We need to define some essential parameters."


# Server tag: suggest current location:
if [ "" = "$mcsInstance" ]; then mcsInstance=${PWD##*/}; fi
echo -n "  1. Server tag: hit Enter to use $mcsInstance or type in a new tag:"
read ans
if [ "" != "$ans" ]; then mcsInstance="$ans"; fi
echo "     Server tag set to $mcsInstance"


# Server port: read from config or fall back to default
# will use same port for query
if [ "" = "$mcsInstancePort" ]; then mcsInstancePort="25565"; fi
echo -n "  2. Server port: hit Enter to use $mcsInstancePort or type in a new port nr.:"
read ans
if [ "" != "$ans" ]; then mcsInstancePort="$ans"; fi 
echo "     Server port set to $mcsInstancePort"


# Server remote console access port
#  disabled by default but still should use a valid port nr.
if [ "" = "$mcsInstanceRPort" ]; then mcsInstanceRPort="25575"; fi
echo "  3. Server rcon port: this will remain inactive, but a valid port number should be set anyway."
echo    "     Suggest to set this to server port + 1"
echo -n "     Hit Enter to use $mcsInstanceRPort or type in a new port nr.:"
read ans
if [ "" != "$ans" ]; then mcsInstanceRPort="$ans"; fi
echo "     Server rcon port set to $mcsInstanceRPort"



# Server long name
echo    "  4. Server description as shown in the launchers server list. "  
echo -n "     Hit Enter to use $mcsInstanceLabel or type in a new description:"
read ans
if [ "" != "$ans" ]; then mcsInstanceLabel="$ans"; fi
echo "     Server description set to $mcsInstanceLabel"


# Server max. Memory
if [ "" = "$mcsInstanceMemory" ]; then mcsInstanceMemory="1G"; fi
echo -n "  5. Server memory (Xmx): hit Enter to use $mcsInstanceMemory or type in a new setting (e.g \"2G\"):"
read ans
if [ "" != "$ans" ]; then mcsInstanceMemory="$ans"; fi
echo "     Server max. memory set to $mcsInstanceMemory"


# Paper Server version
# exit when empty
echo -n "  6. Paper version: hit Enter to install version $mcsPaperVersion or type in a new version (e.g \"1.17.1\"):"
read ans
if [ "" != "$ans" ]; then mcsPaperVersion="$ans"; fi
echo "     Ok, Server version $mcsPaperVersion will be installed."

# World Seed
echo "  7. Use a custom world seed? (Keep empty if you have a world already!)"
if [ "" = "$mcsInstanceSeed" ]; then 
  echo -n "     Hit enter to use $mcsInstanceSeed as given in the config file or type in a new seed:"
else
  echo -n "     Type in a custom seed number or just hit Enter to generate a random world:"
fi
read ans
if [ "" != "$ans" ]; then mcsInstanceSeed="$ans"; fi
if [ "" != "$mcsInstanceSeed" ]; then echo "     New seed: $mcsInstanceSeed"; fi


# can be run by any user
mcsUserName=`whoami`


# write to instance.cfg
sed -i "s/mcsWorkDir=.*/mcsWorkDir=\"$mcsWorkDir\"/g" instance.cfg
sed -i "s/mcsInstance=.*/mcsInstance=\"$mcsInstance\"/g" instance.cfg
sed -i "s/mcsInstancePort=.*/mcsInstancePort=\"$mcsInstancePort\"/g" instance.cfg
sed -i "s/mcsInstanceRPort=.*/mcsInstanceRPort=\"$mcsInstanceRPort\"/g" instance.cfg
sed -i "s/mcsInstanceMemory=.*/mcsInstanceMemory=\"$mcsInstanceMemory\"/g" instance.cfg
sed -i "s/mcsInstanceLabel=.*/mcsInstanceLabel=\"$mcsInstanceLabel\"/g" instance.cfg
sed -i "s/mcsPaperVersion=.*/mcsPaperVersion=\"$mcsPaperVersion\"/g" instance.cfg
sed -i "s/mcsInstanceSeed=.*/mcsInstanceSeed=\"$mcsInstanceSeed\"/g" instance.cfg
# sed -i "s/mcsUserName=.*/mcsUserName=$mcsUserName/g" instance.cfg





## Initial-Install Paper
echo ""
echo "Download Paper Minecraft server..."
wget -O paperclip.jar https://papermc.io/api/v1/paper/$mcsPaperVersion/latest/download
echo "Accepting the EULA..."
echo eula=true >eula.txt

##  Create server.properties  ##
echo "server-port=$mcsInstancePort" >>server.properties
echo "query.port=$mcsInstancePort" >>server.properties
echo "rcon.port=$mcsInstanceRPort" >>server.properties
echo "server-name=$mcsInstanceLabel" >>server.properties
echo "motd=$mcsInstanceLabel" >>server.properties
echo "level-seed=$mcsInstanceSeed" >>server.properties
# world generator settings not yet included...


echo "Building the Minecraft server..."
screen -dmS mcsInitialization java -jar -Xms256M -Xmx1G paperclip.jar
sleep 10
if ! screen -list | grep -q "\.mcsInitialization"; then
  echo "Initialiation task failed!"
  exit 1
else
  echo "Server has been created and initialized. Waiting to stop."
  screen -Rd mcsInitialization -X stuff "stop$(printf '\r')"
  sleep 10
fi


## server parameters ##
echo "Configure server properties.."
source config.sh




##   System service installation   ##
echo "Installing system service..."
touch "$mcsInstance".service
echo "[Unit]" >> "$mcsInstance".service
echo "Description=$mcsInstanceLabel" >> "$mcsInstance".service
echo "After=network-online.target" >> "$mcsInstance".service
echo "[Service]" >> "$mcsInstance".service
echo "User=$mcsUserName" >> "$mcsInstance".service
echo "WorkingDirectory=$mcsWorkDir" >> "$mcsInstance".service
echo "Type=forking" >> "$mcsInstance".service
echo "ExecStartPre=+/bin/chown -R $mcsUserName $mcsWorkDir" >> "$mcsInstance".service
echo "ExecStart=/bin/bash $mcsWorkDir/start.sh" >> "$mcsInstance".service
echo "ExecStop=/bin/bash $mcsWorkDir/stop.sh" >> "$mcsInstance".service
echo "GuessMainPID=no" >> "$mcsInstance".service
echo "TimeoutStartSec=600" >> "$mcsInstance".service
echo "[Install]" >> "$mcsInstance".service
echo "WantedBy=multi-user.target" >> "$mcsInstance".service

sudo cp "$mcsInstance".service /etc/systemd/system/
sudo chown root /etc/systemd/system/"$mcsInstance".service
sudo chgrp root /etc/systemd/system/"$mcsInstance".service
sudo chmod +x /etc/systemd/system/"$mcsInstance".service

# register system service --> will start at statup via start.sh
sudo systemctl daemon-reload
sudo systemctl enable "$mcsInstance".service

echo "Adding instance ports to firewall..."
sudo firewall-cmd --permanent --zone=public --add-port=$mcsInstancePort/tcp
sudo firewall-cmd --permanent --zone=public --add-port=$mcsInstancePort/udp
sudo firewall-cmd --reload

echo " ### You will need to open port $mcsInstancePort in an external firewall or enable port forwarding! ###"


##   Prepare backup services   ##
mkdir backups

echo "A new world backup will be created every night at 04:15 without a server restart."
echo "Doublecheck the current system date and time: $(date)"

## register cron job for backup ##
croncmd="$mcsWorkDir/backup.sh"
cronjob="15 4 * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
echo "Backup will only keep the most recent 5 backups." 





echo "Setup is complete.  Starting Minecraft server..."

mcsInstanceActive=true
sed -i "s/mcsInstanceActive=.*/mcsInstanceActive=$mcsInstanceActive/g" instance.cfg

sudo systemctl start "$mcsInstance".service



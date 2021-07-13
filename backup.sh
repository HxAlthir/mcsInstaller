#!/bin/bash
#  backup minecrtaft world. Server restart is not required
#  script shall be run once a day --> 
#  will keep only 5 most recent backup files
#  backup files should be downloaded by another process to another - longterm storage

#  will take ownership to all files in the server directory --> need sudo 

# load settings
if [ -e "instance.cfg" ]; then
  source instance.cfg
else
  echo "Server setup file instance.cfg not found. Cannot proceed.. Exit."
  exit 1
fi

# Taking ownership of all server files/folders in dirname/minecraft
sudo chown -Rv "$mcsUserName" "$mcsWorkDir"  ||  echo "$(printf '\r') Could not change owner - not a sudoer!"



# Check if server is running
if ! screen -list | grep -q "\.$mcsInstance"; then
  echo "Server $mcsInstance is not running. Will create a backup anyway."
  doSaveOn=false
else
  screen -Rd "$mcsInstance" -X stuff "say Executing world backup in 5 seconds...$(printf '\r')"
  sleep 5
  # disable automatic saving first
  screen -Rd "$mcsInstance" -X stuff "save-off$(printf '\r')"
  # write all sheduled changes to files
  screen -Rd "$mcsInstance" -X stuff "save-all$(printf '\r')"
  # give server some time to save the world
  sleep 5 
  doSaveOn=true
fi


# Back up server
if [ -d "world" ]; then 
    echo "Create a backup into backups folder."
    tar --exclude='./backups' --exclude='./cache' --exclude='./logs' --exclude='./paperclip.jar' -pzvcf backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz ./*
fi

# Rotate backups -- keep most recent 5
Rotate=$(ls -1tr $mcsWorkDir/backups | head -n -5 | xargs -d '\n' rm -f --)


if [ "true" = "$doSaveOn" ]; then
  # Enable automatic saving
  screen -Rd "$mcsInstance" -X stuff "save-on$(printf '\r')"
  screen -Rd "$mcsInstance" -X stuff "say Backup abgeschlossen. Weitermachen und viel Spaß!$(printf '\r')"
fi




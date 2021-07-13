#!/bin/bash
# update paper version
# need to restart server!

# load settings
if [ -e "instance.cfg" ]; then
  source instance.cfg
else
  echo "Server setup file instance.cfg not found. Cannot proceed.. Exit."
  exit 1
fi

# Update paperclip.jar
# TODO: check if there is a newer version and shedule an update only if necessary

# Check if server is running
if ! screen -list | grep -q "\.$mcsInstance"; then
  # echo "Server $mcsInstance is not currently running"
  restartInstance=false
else
  echo -n "Server is running. Shutdown the server and procede?(y/n)?"
  read ans
  if [ "$ans" != "${ans#[Yy]}" ]; then
    echo "Cancelled." ; exit 1
  fi
  bash stop.sh
  restartInstance=true
fi

echo "Downloading most recent paperclip version ..."
wget -O paperclip.jar https://papermc.io/api/v1/paper/$mcsPaperVersion/latest/download

if [ "true" = "$restartInstance" ]; then  bash start.sh ; fi


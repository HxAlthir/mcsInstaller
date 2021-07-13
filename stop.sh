#!/bin/bash
# stop server

# load settings
if [ -e "instance.cfg" ]; then
  source instance.cfg
else
  echo "Server setup file instance.cfg not found. Cannot proceed.. Exit."
  exit 1
fi

# Check if server is running
if ! screen -list | grep -q "\.$mcsInstance"; then
  echo "Server $mcsInstance is not currently running!"
  exit 1
fi

# Stop the server
echo "Stopping Minecraft server $mcsInstance..."
screen -Rd "$mcsInstance" -X stuff "say Closing server in 10s... $(printf '\r')"
sleep 10;
screen -Rd "$mcsInstance" -X stuff "stop$(printf '\r')"

# Wait up to 30 seconds for server to close
StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "\.$mcsInstance"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

# Force quit if server is still open
if screen -list | grep -q "\.$mcsInstance"; then
  echo "Minecraft server $mcsInstance still hasn't closed after 30 seconds, closing screen manually."
  screen -S "$mcsInstance" -X quit
fi

echo "Minecraft server $mcsInstance stopped."

# Sync all filesystem changes out of temporary RAM
sync

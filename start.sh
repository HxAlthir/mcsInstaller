#!/bin/bash
# start server 

# load settings
if [ -e "instance.cfg" ]; then
  source instance.cfg
else
  echo "Server setup file instance.cfg not found. Cannot proceed.. Exit."
  exit 1
fi

# # Flush out memory to disk so we have the maximum available for Java allocation
# sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
sync

# Check if server is already running
if screen -list | grep -q "\.$mcsInstance"; then
    echo "Server $mcsInstance is already running!  Type screen -r $mcsInstance to open the console"
    exit 1
fi

# Check if network interfaces are up
NetworkChecks=0
DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
while [ -z "$DefaultRoute" ]; do
    echo "Network interface not up, will try again in 1 second";
    sleep 1;
    DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
    NetworkChecks=$((NetworkChecks+1))
    if [ $NetworkChecks -gt 20 ]; then
        echo "Waiting for network interface to come up timed out - starting server without network connection ..."
        break
    fi
done

echo "Starting server $mcsInstance.  To view window type screen -r $mcsInstance."
echo "To leave screen and let the server run in the background, press Ctrl+A then D"
screen -dmS "$mcsInstance" java -jar -Xms516M -Xmx"$mcsInstanceMemory" paperclip.jar

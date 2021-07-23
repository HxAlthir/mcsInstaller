#!/bin/bash

# This is the backups collector 
# - Needs to be run on a backup server
# - access keys in users .ssh directory
# - will later cd to backup directories
# - log-file in program directory
# Install cron job manually -> commands see below

logfile="$(pwd)/bkpmgr.log"

# tasks:   go through all instances (define manually!)
#         1. collect new backups every day
#         2. move backup of each first day of the month to longterm backup
#         3. delete remaining backups when elder than 10 days


echo ""; echo ""; echo ""; echo ""
echo "#### Execute new backup task $(date +%d.%m.%Y\ %H:%M)  ####" >> "$logfile"


## Host vmmcserver ##
host="rock@152.70.171.224"
key="~/.ssh/rocksBackupKey"

source1="/opt/minecraft/mcs1/backups/*"
source2="/opt/minecraft/mcs2/backups/*"
source3="/opt/minecraft/mcs3/backups/*"

dest1="/home/rock/minecraft/backups/vmmcserver/mcs1/"
dest2="/home/rock/minecraft/backups/vmmcserver/mcs2/"
dest3="/home/rock/minecraft/backups/vmmcserver/mcs3/"

# to do: subfunction and for-loop of all hosts and instances.
# until then, copy-paste will do


# hidden to prevent messing up with backup deletion
ltbkpdir=".longterm" 

######################################################################################
echo "Host : $host"  >> "$logfile"
######################################################################################



######################################################################################
thissource="$source1"
thisdest="$dest1"
echo " -- instance 1 in $thissource"  >> "$logfile"
######################################################################################
cd "$thisdest"
# 1. Download all new backup files
rsync -vzt --ignore-existing -e "ssh -i $key" "$host:$thissource" "$thisdest" >> "$logfile"
# 2. Find the first backup of the month and move it to long term backup.
# consider only deletion candidates to avoid multiple downloading
# Get date from file name: relies on file naming convention --> todobetter
# grep does not feed mv directly :(
echo "Check for long term backup: each first day of the month." >> "$logfile"
ls -1tr . | head -n -10 | grep $(date +%Y.%m.01) > .newlongterm
if [ -s .newlongterm ]; then
  echo "File $(cat .newlongterm) will be moved to long term backup." >> "$logfile"
  xargs -a .newlongterm mv -f -t "$ltbkpdir" >> "$logfile"
fi
rm .newlongterm
# 3. now delete the remaining..
echo "Delete backups older than 10 days"  >> "$logfile"
# We are already in backups directory, but better safe than..
rot=$(ls -1tr $thisdest | head -n -10 | xargs -d '\n' rm -f --)
######################################################################################




######################################################################################
thissource="$source2"
thisdest="$dest2"
echo " -- instance 2 in $thissource"  >> "$logfile"
######################################################################################
cd "$thisdest"
# 1. Download all new backup files
rsync -vzt --ignore-existing -e "ssh -i $key" "$host:$thissource" "$thisdest" >> "$logfile"
# 2. Find the first backup of the month and move it to long term backup.
# consider only deletion candidates to avoid multiple downloading
# Get date from file name: relies on file naming convention --> todobetter
# grep does not feed mv directly :(
echo "Check for long term backup: each first day of the month." >> "$logfile"
ls -1tr . | head -n -10 | grep $(date +%Y.%m.01) > .newlongterm
if [ -s .newlongterm ]; then #echo "true"; else echo "false"; fi
  echo "File $(cat .newlongterm) will be moved to long term backup." >> "$logfile"
  xargs -a .newlongterm mv -f -t "$ltbkpdir" >> "$logfile"
fi
rm .newlongterm
# 3. now delete the remaining..
echo "Delete backups older than 10 days"  >> "$logfile"
# We are already in backups directory, but better safe than..
rot=$(ls -1tr $thisdest | head -n -10 | xargs -d '\n' rm -f --)
######################################################################################





######################################################################################
thissource="$source3"
thisdest="$dest3"
echo " -- instance 3 in $thissource"  >> "$logfile"
######################################################################################
cd "$thisdest"
# 1. Download all new backup files
rsync -vzt --ignore-existing -e "ssh -i $key" "$host:$thissource" "$thisdest" >> "$logfile"
# 2. Find the first backup of the month and move it to long term backup.
# consider only deletion candidates to avoid multiple downloading
# Get date from file name: relies on file naming convention --> todobetter
# grep does not feed mv directly :(
echo "Check for long term backup: each first day of the month." >> "$logfile"
ls -1tr . | head -n -10 | grep $(date +%Y.%m.01) > .newlongterm
if [ -s .newlongterm ]; then #echo "true"; else echo "false"; fi
  echo "File $(cat .newlongterm) will be moved to long term backup." >> "$logfile"
  xargs -a .newlongterm mv -f -t "$ltbkpdir" >> "$logfile"
fi
rm .newlongterm
# 3. now delete the remaining..
echo "Delete backups older than 10 days"  >> "$logfile"
# We are already in backups directory, but better safe than..
rot=$(ls -1tr $thisdest | head -n -10 | xargs -d '\n' rm -f --)
######################################################################################




## Host 2 ##
# nothing here yet


### finished ####
exit 0





######################################################################################
bmworkdir="/home/rock/bkpmgr"
######################################################################################


######################################################################################
## register cron job for backup
croncmd="$bmworkdir/bkpmgr.sh"
# cron executes everything in users home. -.-
cronjob="30 5 * * * cd $bmworkdir && $croncmd > lastjob.log 2>&1"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
echo "Backup will only keep the most recent 5 backups." 
######################################################################################


######################################################################################
## unregister cron job for backup
croncmd="$bmworkdir/bkpmgr.sh"
( crontab -l | grep -v -F "$croncmd" ) | crontab -
######################################################################################








#############################
# Rotate backups -- keep most recent 10
#############################
#Rotate=$(ls -1tr $mcsWorkDir/backups | head -n -10 | xargs -d '\n' rm -f --)
# ls -1tr : one file per line reverse sorting by time (default:mtime)
# head -n -<x> : replot all but first <x> lines (minus<x>)
# xargs [options] [command [initial-arguments]]
#   calls <command> with options for e.g. each line of input
#   -d '\n' : delimiter = new line 
#   <command> = rm
#     rm initial options : -f : force
#############################


#############################
# scp ...
# C : use compression 
# cannot ignore-existing
#############################


#############################
# rsync [OPTION...] SRC... [DEST]
# PULL
# rsync [OPTION...] [USER@]HOST:SRC... [DEST]
# -z, --compress  → ja gern 
# -c. --checksum  → vielleicht
# --ignore-existing → vielleicht
# -a  =  -rlptgoD (no -H,-A,-X)  → nein
# --delete : = purge → nein
# -u : update : 
# -n : dry-run
# -r : rekursiv → nicht nötig
# -l : copy symlinks as symlinks → nicht nötig
# -p : preserve permissions → nicht nötig
# -t : preserve modification times → ist mir egal → Korrektur: ist mir garnicht egal.
# -g : preserve group → nein
# -o : preserve owner (super-user only) → nein
# -D : same as --devices --specials / → total egal
# -v : verbose

# rsync -vz -e "ssh -i $key" "$host:$thissource" "$thisdest"






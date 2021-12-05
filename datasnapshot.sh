#!/bin/bash
# BeBaToE Best Backup Tool Ever
# 
# Call syntax:
#      datasnapshot  path_to_source  path_to_backups_folder  (comparison_method)
# 
# - path_to_source : data to be backuped
# - path_to_backups_folder : where to store backups  !! no other data may be in here !!
# - comparison Methods can be: "time"(default) or "sha256"
# 
# The script creates backups of a specified source folder in a subfolder of the
# backups folder. the new backup is created in a new subfolder named based 
# on date and time. The first backup is always a copy of the source.
# 
# The latter backups are file-incremental backups related to the latest backup
# files are compared based on change date and time or with SHA256 hash.
# For each unchanged file a hard link is created thus saving drive space.
# For changed or added files copies are created.
# Files that are deleted from source are not copied or linked.
# We will totally skip symbolic links of any kind.

## tested special characters in file or folder names:
# . - white space , | \ : ( ) & ; ? * > < " ' `

# sourcefolder="/opt/minecraft/papertest"
# backupfolder="/media/vmmcserver/backup/papertest"

sourcefolder="$1"
backupfolder="$2"
if [ "" = "$sourcefolder" ] || [ "" = "$backupfolder"]; then 
  echo "Not enough arguments: need source and backup folders"; exit 1
fi

METHOD="$3"

case "$METHOD" in
  "time" | "") # compare by file change date+time : default!
    CMPMETHOD=0
    ;;
  "sha256")  # compare by sha256
    CMPMETHOD=1
    ;;
  *)
    echo "Unknown comparison method $METHOD. Use 'time' or 'sha256'"
    exit 1
    ;;
esac

# Skript läuft mit user Berechtigungen. Alle Dateien müssen entsprechende Berechtigungen haben.

# Archivierungs- bzw. Vergleichsmethoden:
# Wenn die Datei in Quelle und in Backup vorhanden ist:

# ### mit dem archivbit ###
# nur kopieren wenn Archivbit gesetzt ist : d.h. neu oder geändert 
# Beim archivieren muss das Archivbit in der Quelle entfernt werden
# Archivbit setzt eine Änderung der Quelle voraus
# => wir pfeifen auf das Archivbit. 

# ### mit Änderungszeit ###
# nur kopieren wenn Änderungszeit der Quelle neuer ist als im Backup
# => wird verwendet mit CMPMETHOD=2

# ### mit Änderungszeit und Dateigröße ###
# nur kopieren wenn Änderungszeit der Quelle neuer ist als in der Referentz 
# oder die Dateigröße weicht ab ??
# => nein

# ### mit Checksumme ###
# kopieren wenn die Checksumme unterschiedlich ist
# SHA256 
# => wird verwendet mit CMPMETHOD=1



currentfolder="$(pwd)"
errorlog="$currentfolder/errorlog.log"


if [ ! -e "$sourcefolder" ]; then echo Source folder not found!; exit 1; fi
if [ ! -e "$backupfolder" ]; then echo Backups folder not found!; exit 1; fi

echo
echo "------- Backup -------"
echo "Source folder: $sourcefolder"
echo "Backups folder: $backupfolder"
thisbackup=`date +"%Y%m%d_%H%M%S"`
echo "New snapshot: $thisbackup"

# write to error log file
echo >> "$errorlog"
echo "Snapshot: $thisbackup" >> "$errorlog"
echo "Sources folder: $sourcefolder" >> "$errorlog"
echo "Backups folder: $backupfolder" >> "$errorlog"

# read former backups
cd "$backupfolder"

# scan subfolders for backups
dmax="00000000" # Date
for fname in *; do
  if [ -d "$fname" ]; then  dnum="${fname:0:8}"
    if [ "$dnum" \> "$dmax" ]; then dmax="$dnum"; fi
  fi
done

cmax="000000" # Time
if  [ "00000000" = "$dmax" ]; then initial=1; else initial=0;
  for fname in *; do
    if [ -d "$fname" ]; then dnum="${fname:0:8}"
      if [ "$dnum" = "$dmax" ]; then cnum="${fname:9:6}"
        if [ "$cnum" \> "$cmax" ]; then cmax="$cnum"; fi
      fi
    fi
  done
fi

lastbackup="$dmax"_"$cmax"
echo "Latest backup: $lastbackup"
echo "  (Initial: $initial)"
echo
ERRCNT=0
# bkpFolder "$sourcefolder" "$backupfolder/$thisbackup" $initial "$backupfolder/$lastbackup"

########  Define subfunction bkpFolder  ##############
function bkpFolder {

local thissourcefolder="$1"
local thisbackupfolder="$2"
local thisinitial=$3
local thislastbackup="$4"

# echo "Recursive call inputs:"
# echo "  source: $thissourcefolder"
# echo "  Backup: $thisbackupfolder"
# echo "  IsInitial: $thisinitial"
# echo "  Reference: $thislastbackup"

cd "$thissourcefolder"
mkdir "$thisbackupfolder"

# issue with empty directories - "for" returns fake file "*"
if [[ -n `ls -A` ]]; then # directory is not empty, hence loop contents 

# loop files
for fname in *; do
  if [ ! -d "$fname" ]; then
    # echo "  processing file: $fname"
    filechanged=1
    if [ $thisinitial -eq 0 ]; then
      if [ -e "$thislastbackup/$fname" ]; then
        echo "  File found in lastbackup"
        if [ $CMPMETHOD -eq 1 ]; then  # sha256
          hash1=`sha256sum "$fname" | cut -f 1 -d " "`
          hash2=`sha256sum "$thislastbackup/$fname" | cut -f 1 -d " "`
          # echo "      hash1: $hash1"
          # echo "      hash2: $hash2"
          if [ "" = "$hash1" ]; then
            echo "  Failed to calculate checksum for source file $fname"
            echo "  Failed to calculate checksum for source file $fname" >> "$errorlog"
            echo "  in $thissourcefolder" >> "$errorlog"
            ERRCNT=$(($ERRCNT+1))
          else
            if [ "" = "$hash2" ]; then
              echo "  Failed to calculate checksum for reference file $fname"
              echo "  Failed to calculate checksum for reference file $fname" >> "$errorlog"
              echo "  in $thislastbackup" >> "$errorlog"
              ERRCNT=$(($ERRCNT+1))
            else 
              if [ "$hash1" = "$hash2" ]; then filechanged=0; fi
            fi
          fi
        else # date+time 
          tstamp1=`date -r "$fname" +"%Y%m%d_%H%M%S"`
          tstamp2=`date -r "$thislastbackup/$fname" +"%Y%m%d_%H%M%S"`
          # echo "      tstamp1: $tstamp1"
          # echo "      tstamp2: $tstamp2"
          if [ "" = "$tstamp1" ]; then
            echo "  Failed to calculate time stamp for source file $fname"
            echo "  Failed to calculate time stamp for source file $fname" >> "$errorlog"
            echo "  in $thissourcefolder" >> "$errorlog"
            ERRCNT=$(($ERRCNT+1))
          else
            if [ "" = "$tstamp2" ]; then
              echo "  Failed to calculate time stamp for reference file $fname"
              echo "  Failed to calculate time stamp for reference file $fname" >> "$errorlog"
              echo "  in $thislastbackup" >> "$errorlog"
              ERRCNT=$(($ERRCNT+1))
            else
              if [ "$tstamp1" = "$tstamp2" ]; then filechanged=0; fi
            fi
          fi
        fi
      else
        echo "  not found in lastbackup: new file"
      fi
    # else # initial: copy all files
    fi
    
    if [ $filechanged -eq 1 ]; then
      # echo "    File new or changed - will create a copy"
      # -p: preserve attributes, -P: skip symbol links
      cp -pP "$fname" "$thisbackupfolder/$fname" >> "$errorlog"
      if [ ! $? -eq 0 ]; then
        echo "  Error copying file $fname"
        echo "  Error copying file $fname" >> "$errorlog"
        echo "  from $thissourcefolder to $thisbackupfolder" >> "$errorlog"
        ERRCNT=$(($ERRCNT+1))
      fi
    else
      # echo "    File not changed - will create a hard link"
      cp --link -P "$thislastbackup/$fname" "$thisbackupfolder/$fname" >> "$errorlog"
      if [ ! $? -eq 0 ]; then
        echo "  Error creating hard link for file $fname"
        echo "  Error creating hard link for file $fname" >> "$errorlog"
        echo "  in $thislastbackup and $thisbackupfolder" >> "$errorlog"
        ERRCNT=$(($ERRCNT+1))
      fi
    fi
  fi
done

local subsourcefolder
local subbackupfolder
local subinitial=1
local sublastbackup="00000000"

# loop subfolders
for fname in *; do
  if [ -d "$fname" ]; then
    echo "  Processing directory $fname"
    subsourcefolder="$thissourcefolder/$fname"
    subbackupfolder="$thisbackupfolder/$fname"
    if [ ! $thisinitial -eq 1 ]; then
      if [ -d "$thislastbackup/$fname" ]; then 
        subinitial=0
        sublastbackup="$thislastbackup/$fname"
      fi
    fi
    ### recursive call ####
    bkpFolder "$subsourcefolder" "$subbackupfolder" $subinitial "$sublastbackup"
    cd "$thissourcefolder"
  fi
done 

fi # if dir isempty

return 0
}

##### recursive call of subfcn #####
bkpFolder "$sourcefolder" "$backupfolder/$thisbackup" $initial "$backupfolder/$lastbackup"

cd "$currentfolder"
if [ $ERRCNT -gt 0 ]; then
  echo "-- finished with $ERRCNT errors. See $errorlog for details --"
  echo "-- finished with $ERRCNT errors --" >> "$errorlog"
else
  echo  "-- finished --"
  echo  "-- finished without errors --" >> "$errorlog"
fi

exit 0
#####  END  #####








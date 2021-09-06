#!/bin/bash
## Java 16 installieren ##


echo "nicht getested! Abbruch."
exit 1

# über rpm package installieren - das macht alternates automatisch!
##############################################################################


if [ $(id -u) = 0 ]; then
  echo "Nicht mit sudo starten."
  exit 1
fi

if [ -n "$(which java)" ]; then
  echo -n "Std. Java ist installiert. Weiter mit Version 16? ? "
  read ans 
  if [ "$ans" != "${ans#[Yy]}" ]; then
    exit 1
  fi
else
  echo "Es ist noch garkeine Java Version vorhanden."
  echo -n "Std.java mit 'sudo yum install java' installieren?"
  read ans 
  if [ "$ans" != "${ans#[Yy]}" ]; then
    sudo yum install java
  else
    echo "Abbrcuh."
    exit 1
  fi
fi


mkdir ~/tempdownload
cd ~/tempdownload

# Link von irgendeiner Oracle Website.. sollte eigentlich auch sha256 prüfen...
# wget https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL/openjdk-16.0.1_linux-aarch64_bin.tar.gz



cd /usr/java/
sudo tar -xvzf ~/tempdownload/openjdk-16.0.1_linux-aarch64_bin.tar.gz
cd ~/tempdownload
rm ~/tempdownload/openjdk-16.0.1_linux-aarch64_bin.tar.gz
rmdir ~/tempdownload

# Mit "alternatives" zu arbeiten ist einfach ganz große Sch-.. Freude

# Oracle Java ist in /usr/java installiert und per alternatives in usr/bin/ verlinkt

# "Alternatives" installiert die java executable als "alternative" - und 
# sämtliche anderen executables aus dem Java Ordner müssen beim Aufruf als "slaves"
# mit angegeben werden, nachträglich geht nicht..

linkpath="/usr/bin"
sourcepath="/usr/java/jdk-16.0.1/bin"

# Die alte Version v11.0.11.0.1 hatte die Prio 1100 1100 0 - dann muss die neue Version 16.0.1 natürlich eine höhere Prio erhalten..
priority=160001000

# slave parameter
dfs () {
  echo "--slave $linkpath/$1 $1 $sourcepath/$1"
}

# master
dfa () {
  echo "--install $linkpath/$1 $1 $sourcepath/$1"
}

altCmd="alternatives $(dfa java) $priority " 
altCmd="$altCmd $(dfs jar         ) "
altCmd="$altCmd $(dfs jarsigner   ) "
altCmd="$altCmd $(dfs javac       ) "
altCmd="$altCmd $(dfs javadoc     ) "
altCmd="$altCmd $(dfs javap       ) "
altCmd="$altCmd $(dfs jcmd        ) "
altCmd="$altCmd $(dfs jconsole    ) "
altCmd="$altCmd $(dfs jdb         ) "
altCmd="$altCmd $(dfs jdeprscan   ) "
altCmd="$altCmd $(dfs jdeps       ) "
altCmd="$altCmd $(dfs jfr         ) "
altCmd="$altCmd $(dfs jhsdb       ) "
altCmd="$altCmd $(dfs jimage      ) "
altCmd="$altCmd $(dfs jinfo       ) "
altCmd="$altCmd $(dfs jlink       ) "
altCmd="$altCmd $(dfs jmap        ) "
altCmd="$altCmd $(dfs jmod        ) "
altCmd="$altCmd $(dfs jpackage    ) "
altCmd="$altCmd $(dfs jps         ) "
altCmd="$altCmd $(dfs jrunscript  ) "
altCmd="$altCmd $(dfs jshell      ) "
altCmd="$altCmd $(dfs jstack      ) "
altCmd="$altCmd $(dfs jstat       ) "
altCmd="$altCmd $(dfs jstatd      ) "
altCmd="$altCmd $(dfs keytool     ) "
altCmd="$altCmd $(dfs rmid        ) "
altCmd="$altCmd $(dfs rmiregistry ) "
altCmd="$altCmd $(dfs serialver   ) "

sudo $altCmd

echo "Fertig. Java Versionen lassen sich nun mit alternatives umschalten."



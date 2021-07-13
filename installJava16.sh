#!/bin/bash
## Java 16 installieren ##


if [ $(id -u) = 0 ]; then
  echo "Nicht mit sudo starten!"
  exit 1
fi


echo "Dies ist ein Skript, das man je nach Bedarf anpassen muss. Also im Editor öffnen und Schritt für Schritt durchgehen."
exit 1


mkdir ~/tempdownload
cd ~/tempdownload

# Link von irgendeiner Oracle Website.. sollte eigentlich auch sha256 prüfen...
wget https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL/openjdk-16.0.1_linux-aarch64_bin.tar.gz

cd /usr/java/

sudo tar -xvzf ~/tempdownload/openjdk-16.0.1_linux-aarch64_bin.tar.gz

cd ~/tempdownload
rm ~/tempdownload/openjdk-16.0.1_linux-aarch64_bin.tar.gz
rmdir ~/tempdownload


# Mit "alternatives" zu arbeiten ist einfach ganz große Freude ;-@ ....
sudo ./installJavaAlternative.sh

# Wenn wir ohne sudo starten - wird der Alternatives-Aufruf nur als test ausgegeben.

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

altCmd=alternatives $(dfa java) "$priority" \
    $(dfs jar         ) \
    $(dfs jarsigner   ) \
    $(dfs javac       ) \
    $(dfs javadoc     ) \
    $(dfs javap       ) \
    $(dfs jcmd        ) \
    $(dfs jconsole    ) \
    $(dfs jdb         ) \
    $(dfs jdeprscan   ) \
    $(dfs jdeps       ) \
    $(dfs jfr         ) \
    $(dfs jhsdb       ) \
    $(dfs jimage      ) \
    $(dfs jinfo       ) \
    $(dfs jlink       ) \
    $(dfs jmap        ) \
    $(dfs jmod        ) \
    $(dfs jpackage    ) \
    $(dfs jps         ) \
    $(dfs jrunscript  ) \
    $(dfs jshell      ) \
    $(dfs jstack      ) \
    $(dfs jstat       ) \
    $(dfs jstatd      ) \
    $(dfs keytool     ) \
    $(dfs rmid        ) \
    $(dfs rmiregistry ) \
    $(dfs serialver   )

sudo $altCmd

echo "Fertig. Java Versionen lassen sich nun mit alternatives umschalten."





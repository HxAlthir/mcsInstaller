# mcsInstaller

---> Experimental! <---

Scripts to set up a new minecraft server on a linux mashine (here on an Oracle VM / RedHat-Linux - see below for more)

Setup one or several minecraft servers (worlds) that can share the ressources on a single mashine.

Copy script files to a subfolder like e.g.:  '/opt/minecraft/mcserver1'

Set permissions to user, mark executable 

<code>
  chown opc:opc *
  
  chmod +x *.sh
</code>
  
run install.sh

Currently defined server software : PaperMC

Java16 Installer is included but needs to be run separately - quick&dirty


Inspired by: / Thanks goes to:

Scripts for a raspberryPi by James A. Chambers - https://jamesachambers.com
https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service/

https://github.com/TheRemote/RaspberryPiMinecraft


Installation on an Oracle VM :

https://blogs.oracle.com/developers/how-to-set-up-and-run-a-really-powerful-free-minecraft-server-in-the-cloud




#!/bin/bash
#
#

# Clear Current Screen
clear

# Check Session Status
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
elif [[ $EUID -eq 0 ]]; then
   echo -e "Session Running as \e[36mROOT\e[0m"
fi

echo ""
echo "#############################################"
echo "#                                           #"
echo "#  AnarchyPE Automated Node Update Script   #"
echo "#  Version 0.1-Alpha                        #"
echo "#                                           #"
echo "#############################################"

# Change to Pterodactyl Web Directory
cd /srv/daemon
echo ""

# Download Latest Panel
echo ""
echo " So your are wanting to update your panel??"
echo " Please Visit: https://github.com/pterodactyl/daemon/releases"
echo " Copy the link for the daemon.tar.gz and paste below!"
echo ""

read -p "Paste Here: " NodeRepo
curl -L $NodeRepo | tar --strip-components=1 -xzv

# Upgrade Node
echo ""
echo "############################################"
echo "#                                          #"
echo "#       Upgrading Pterodactyl Daemon       #"
echo "#                                          #"
echo "############################################"

npm install --only=production
systemctl restart wings

# Upgrade NodeJS
npm install -g npm

echo ""
echo "############################################"
echo "#                                          #"
echo "#  Pterodactyl Daemon upgrade completed!!  #"
echo "#                                          #"
echo "############################################"

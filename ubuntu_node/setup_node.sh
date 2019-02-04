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
   echo -e "Session Running as \e[36mROOT...\e[0m"
fi

echo ""
echo "############################################"
echo "#                                          #"
echo "#   AnarchyPE Automated Node Setup Script  #"
echo "#   Version 0.1-Alpha                      #"
echo "#                                          #"
echo "############################################"


# Update System and Local Packages
echo ""
echo "############################################"
echo "#                                          #"
echo "#  Updating Local Repository and Packages  #"
echo "#                                          #"
echo "############################################"

apt-get update && apt-get -y upgrade

# Install Pterodactyl Node Packages
echo ""
echo "############################################"
echo "#                                          #"
echo "#   Installing Pterodactyl Node Packages   #"
echo "#                                          #"
echo "############################################"

apt-get -y install zip unzip tar make gcc g++ python \
                   python-dev docker.io nodejs npm

# Enable Docker Service
systemctl enable docker
systemctl start docker

# Install Daemon Software
echo ""
echo "############################################"
echo "#                                          #"
echo "#  Installing Pterodactyl Daemon Software  #"
echo "#                                          #"
echo "############################################"

mkdir -p /srv/daemon /srv/daemon-data
cd /srv/daemon
wget https://github.com/pterodactyl/daemon/archive/master.zip
unzip master.zip && rm master.zip && mv /srv/daemon/daemon-master/* /srv/daemon/ && rm $



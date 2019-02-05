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

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get -y install zip unzip tar make gcc g++ python \
                   python-dev docker.io nodejs certbot
npm upgrade 

# Enable Docker Service
systemctl enable docker
systemctl start docker

# Generate LetsCrypt
echo ""
echo "############################################"
echo "#                                          #"
echo "#     Generate Certbot SSL Certificate     #"
echo "#                                          #"
echo "############################################"


echo ""
echo "Please enter the FQDN for the Pyterdactyl Node"
read nodefqdn
#certbot certonly -d  pterodactyl-node01.azuriscraft.co.uk --manual --preferred-challenges dns
certbot certonly -d "$nodefqdn" --manual --preferred-challenges dns


# Install Daemon Software
echo ""
echo "############################################"
echo "#                                          #"
echo "#  Installing Pterodactyl Daemon Software  #"
echo "#                                          #"
echo "############################################"

mkdir -p /srv/daemon /srv/daemon-data
cd /srv/daemon
curl -L https://github.com/pterodactyl/daemon/releases/download/v0.6.11/daemon.tar.gz | tar --strip-components=1 -xzv
npm install --only=production
npm audit fix


#
# PULL DOWN CONFIG FROM PANEL
#
npm start

# Configure Wings Service
wget https://raw.githubusercontent.com/anarchype/AnarchyPE/master/ubuntu_node/wings.service -O /etc/systemd/system/wings.service
systemctl enable wings
systemctl start wings


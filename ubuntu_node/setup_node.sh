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
read -p "Enter FQDN: " nodefqdn
certbot certonly -d "$nodefqdn" --manual --preferred-challenges dns --register-unsafely-without-email

# Install Daemon Software
echo ""
echo "############################################"
echo "#                                          #"
echo "#  Installing Pterodactyl Daemon Software  #"
echo "#                                          #"
echo "############################################"

# Create Daemon Directory
mkdir -p /srv/daemon /srv/daemon-data
cd /srv/daemon

# Download Latest Panel
echo ""
echo " New Node? You need to get you some Pterodactyl Daemon goodness!!"
echo " Please Visit: https://github.com/pterodactyl/daemon/releases"
echo " Copy the link for the daemon.tar.gz and paste below!"
echo ""

read -p "Paste Here: " NodeRepo
curl -L $NodeRepo | tar --strip-components=1 -xzv
npm install --only=production

echo ""
echo " Configure the Pterodactyl Daemon"
echo " Please go to the control panel and create"
echo " a new node and generate the automated token key"
echo ""

read -p "Paste Here: " NodeToken
$NodeToken

# Configure Wings Service
wget https://raw.githubusercontent.com/anarchype/AnarchyPE/master/ubuntu_node/wings.service -O /etc/systemd/system/wings.service
systemctl enable wings
systemctl start wings

echo ""
echo "###############################################"
echo "#                                             #"
echo "#  Pterodactyl Node Initial Setup Completed!  #"
echo "#  Please Check Node status under your panel  #"
echo "#                                             #"
echo "###############################################"
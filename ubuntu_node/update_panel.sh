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
echo "#  AnarchyPE Automated Panel Update Script  #"
echo "#  Version 0.1-Alpha                        #"
echo "#                                           #"
echo "#############################################"

# Change to Pterodactyl Web Directory
cd /var/www/pterodactyl
echo ""

# Place Panel into Mainenace mode and Block Active Logins
php artisan down

# Download Latest Panel
echo ""
echo " So your are wanting to update your panel??"
echo " Please Visit: https://github.com/pterodactyl/panel/releases/"
echo " Copy the link for the panel.tar.gz and paste below!"
echo ""

read -p "Paste Here: " PanelRepo
curl -L $PanelRepo | tar --strip-components=1 -xzv
chmod -R 755 storage/* bootstrap/cache
echo ""

# Update Dependencies
composer install --no-dev --optimize-autoloader
echo ""

# Reset Complied Template Cache
php artisan view:clear
echo ""

# Update Database
php artisan migrate --force
php artisan db:seed --force

# Reset Permisisons for Web Directory # UBUNTU
chown -R www-data:www-data *

# Restore Panel to Acitve Mode - Allows Log Authentication
php artisan up
php artisan queue:restart

echo ""
echo "############################################"
echo "#                                          #"
echo "#  Pterodactyl Panel upgrade completed!!   #"
echo "#                                          #"
echo "############################################"

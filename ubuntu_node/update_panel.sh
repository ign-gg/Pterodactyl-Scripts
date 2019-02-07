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

# Place Panel into Mainenace mode and Block Active Logins
php artisan down

# Download Latest Panel
curl -L https://github.com/pterodactyl/panel/releases/download/v0.7.12/panel.tar.gz | tar --strip-components=1 -xzv
chmod -R 755 storage/* bootstrap/cache

# Update Dependencies 
composer install --no-dev --optimize-autoloader

# Reset Complied Template Cache
php artisan view:clear

# Update Database 
php artisan migrate --force
php artisan db:seed --force

# Reset Permisisons for Web Directory # UBUNTU
chown -R www-data:www-data * 

# Restore Panel to Acitve Mode - Allows Log Authentication
php artisan up
php artisan queue:restart
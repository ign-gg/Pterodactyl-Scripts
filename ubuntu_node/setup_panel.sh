#!/bin/bash
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
echo "#  AnarchyPE Automated Panel Setup Script  #"
echo "#  Version 0.1-Alpha                       #"
echo "#                                          #"
echo "############################################"

# Update System and Local Packages
echo ""
echo "############################################"
echo "#                                          #"
echo "#  Updating Local Repository and Packages  #"
echo "#                                          #"
echo "############################################"

apt update && apt -y upgrade
apt -y install software-properties-common curl

# Install Pterodactyl Panel Packages
echo ""
echo "############################################"
echo "#                                          #"
echo "#   Installing Pterodactyl Dependancies    #"
echo "#                                          #"
echo "############################################"

mariadb_repo_setup=/etc/apt/sources.list.d/mariadb.list
if [ -f mariadb_repo_setup ]; then
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:chris-lea/redis-server
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
fi

apt update
apt-add-repository universe

apt -y install php7.2 php7.2-cli php7.2-gd php7.2-mysql php7.2-pdo php7.2-mbstring \
                   php7.2-tokenizer php7.2-bcmath php7.2-xml php7.2-fpm php7.2-curl \
                   php7.2-zip mariadb-server mariadb-client nginx tar unzip git redis-server \
                   certbot expect composer wget dialog redis

DockerContainer=/.dockerenv
if [ -f $DockerContainer ]; then
   echo ""
   apt -y install screen
   
   # Enable and Start Local System Services
   service mysql start
   service nginx start
   screen -dmS redis-server && screen -S redis-server -p 0 -X stuff 'redis-server'

else
   echo ""
   # Enable and Start Local System Services
   systemctl enable mysql
   systemctl start mysql

   systemctl enable nginx
   systemctl start nginx

fi

# Execute mysql_secure_installation
SECURE_MYSQL=$(expect -c "
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo ""
echo "mysql_secure_installation completed!"

# Configure Panel Database
MySQLUserPwd=$(openssl rand -base64 21)

echo ""
echo "Please Enter Root MySQL Password to execute mysql_secure_installation"
mysql -u root -p <<MYSQL_SCRIPT
USE mysql; CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$MySQLUserPwd';
CREATE DATABASE panel; GRANT ALL PRIVILEGES
ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION; FLUSH
PRIVILEGES;
exit
MYSQL_SCRIPT

echo ""
echo ""
echo "MySQL Database: Panel Created!"
echo "Please take note of these details, as you require them later on!"
echo ""
echo "Database: panel"
echo "Username: pterodactyl"
echo "Password: $MySQLUserPwd"

# Install Pterodactyl Panel
echo ""
echo "############################################"
echo "#                                          #"
echo "#         Install Pterodactyl Panel        #"
echo "#                                          #"
echo "############################################"

echo ""
echo " New Panel? You need to get you some Pterodactyl Panel goodness!!"
echo " Please Visit: https://github.com/pterodactyl/panel/releases"
echo " Copy the link for the panel.tar.gz and paste below!"
echo ""

read -p "Paste Here: " PanelRepo

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz $PanelRepo
tar --strip-components=1 -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# Configure Pterodactyl Panel
echo ""
echo "############################################"
echo "#                                          #"
echo "#       Configure Pterodactyl Panel        #"
echo "#                                          #"
echo "############################################"

cp .env.example .env
composer install --no-dev --optimize-autoloader

# Only run the command below if you are installing this Panel for
# the first time and do not have any Pterodactyl Panel data in the database.
php artisan key:generate --force

php artisan p:environment:setup
php artisan p:environment:database

# To use PHP's internal mail sending (not recommended), select "mail". To use a
# custom SMTP server, select "smtp".
php artisan p:environment:mail

php artisan migrate --seed
php artisan p:user:make

chown -R www-data:www-data *
service nginx restart

wget https://raw.githubusercontent.com/anarchype/AnarchyPE/master/ubuntu_node/pteroq.service -O /etc/systemd/system/pteroq.service

DockerContainer=/.dockerenv
if [ -f $DockerContainer ]; then
   # Enable and Start Local System Services
   service pteroq start
else
   # Enable and Start Local System Services
   systemctl enable pteroq
   systemctl start  pteroq
fi 

# Configure Nginx SSL
echo ""
echo "############################################"
echo "#                                          #"
echo "#      Generate Panel SSL Certificate      #"
echo "#                                          #"
echo "############################################"

echo ""
echo "Please enter the FQDN for the Pyterdactyl Panel"
read -p "Enter FQDN: " panelfqdn
certbot certonly -d "$panelfqdn" --manual --preferred-challenges dns --register-unsafely-without-email

echo ""
echo ""
echo "############################################"
echo "#                                          #"
echo "#      Configure Pterodactyl Panel SSL     #"
echo "#                                          #"
echo "############################################"

# Download ssl config
wget https://raw.githubusercontent.com/anarchype/AnarchyPE/master/ubuntu_node/pterodactyl.conf -O /etc/nginx/sites-available/pterodactyl.conf

# Configure default website and restart nginx service
sed -i -e "s/<domain>/"$panelfqdn"/g" /etc/nginx/sites-available/pterodactyl.conf
ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf && service nginx restart

# Final Message
echo ""
echo " Panel Setup Completed!! Please go to: https://$panelfqdn "
echo ""

#!/bin/sh

script_log_file="script_log.log"
green_color="\033[1;32m"
no_color="\033[0m"
MYSQL_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)


while getopts d: flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
    esac
done




echo $no_color"PREPAIRE INSTALLING";
rm -rf /var/lib/dpkg/lock >> $script_log_file 2>/dev/null
rm -rf /var/lib/dpkg/lock-frontend >> $script_log_file 2>/dev/null
rm -rf /var/cache/apt/archives/lock >> $script_log_file 2>/dev/null
sudo apt-get update  >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"REMOVING APACHE";
sudo apt-get purge apache -y >> $script_log_file 2>/dev/null
sudo apt-get purge apache* -y >> $script_log_file 2>/dev/null
sudo kill -9 $(sudo lsof -t -i:80) >> $script_log_file 2>/dev/null
sudo kill -9 $(sudo lsof -t -i:443) >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING NGINX";
sudo apt-get update   >> $script_log_file 2>/dev/null
sudo apt install nginx -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"OPEN NGINX PORTS";
echo "y" | sudo ufw enable  >> $script_log_file 2>/dev/null
sudo ufw allow 'Nginx HTTP' >> $script_log_file 2>/dev/null
sudo ufw allow 'Nginx HTTPS' >> $script_log_file 2>/dev/null
sudo ufw allow '8443' >> $script_log_file 2>/dev/null
sudo ufw allow OpenSSH  >> $script_log_file 2>/dev/null
sudo add-apt-repository universe -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING NGINX";
sudo pkill -f nginx & wait $! >> $script_log_file 2>/dev/null
sudo systemctl start nginx >> $script_log_file 2>/dev/null
sudo service nginx restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING PHP 7.4";
sudo apt-get update  >> $script_log_file 2>/dev/null
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y >> $script_log_file 2>/dev/null
sudo add-apt-repository ppa:ondrej/php -y >> $script_log_file 2>/dev/null
sudo apt-get update  >> $script_log_file 2>/dev/null
sudo apt install php7.4 -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"INSTALLING PHP EXTENSIONS";
sudo apt install php7.4 openssl php7.4-fpm php7.4-common php7.4-curl php7.4-mbstring php7.4-mysql php7.4-xml php7.4-zip php7.4-gd php7.4-cli php7.4-imagick php7.4-xml php7.4-intl -y >> $script_log_file 2>/dev/null
sudo apt-get purge apache -y >> $script_log_file 2>/dev/null
sudo apt-get purge apache* -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"INSTALLING NPM";
sudo apt install npm -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $green_color"[######################################]";
echo $no_color"INSTALLING COMPOSER";
sudo apt-get update  >> $script_log_file 2>/dev/null
sudo apt-get purge composer -y >> $script_log_file 2>/dev/null
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" >> $script_log_file 2>/dev/null
php composer-setup.php >> $script_log_file  2>/dev/null
sudo mv composer.phar /usr/local/bin/composer >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING NGINX";
sudo pkill -f nginx & wait $! >> $script_log_file 2>/dev/null
sudo systemctl start nginx >> $script_log_file 2>/dev/null
sudo service nginx restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"CREATING NGINX FILE FOR $domain";
sudo rm -rf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default >> $script_log_file 2>/dev/null
sudo touch /etc/nginx/sites-available/$domain >> $script_log_file 2>/dev/null
sudo bash -c "echo 'server {
    listen 80;
    listen [::]:80;
    root /var/www/html/'$domain'/public;
    index index.php index.html index.htm index.nginx-debian.html;
    server_name '$domain' www.'$domain';
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }
    location ~ /\.ht {
            deny all;
    }
}' > /etc/nginx/sites-available/$domain" >> $script_log_file 2>/dev/null
ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/ >> $script_log_file 2>/dev/null
sudo mkdir /var/www/html/$domain >> $script_log_file 2>/dev/null
sudo mkdir /var/www/html/$domain/public >> $script_log_file 2>/dev/null
sudo bash -c "echo  '<h1 style=\"color:#0194fe\">Welcome</h1><h4 style=\"color:#0194fe\">$domain</h4>' > /var/www/html/$domain/public/index.php" >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING NGINX";
sudo pkill -f nginx & wait $! >> $script_log_file 2>/dev/null
sudo systemctl start nginx >> $script_log_file 2>/dev/null
sudo service nginx restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"RESTARTING NGINX";
sudo service nginx restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

if ! [ -x "$(command -v mysql)"  >> $script_log_file 2>/dev/null ]; then
echo $no_color"INSTALLING MYSQL";
export DEBIAN_FRONTEND=noninteractive
echo debconf mysql-server/root_password password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections >> $script_log_file 2>/dev/null
echo debconf mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections >> $script_log_file 2>/dev/null
sudo apt-get -qq install mysql-server  >> $script_log_file 2>/dev/null

sudo apt-get -qq install expect >> $script_log_file 2>/dev/null
tee ~/secure_our_mysql.sh << EOF >> $script_log_file 2>/dev/null 
spawn $(which mysql_secure_installation)

expect "Enter password for user root:"
send "$MYSQL_ROOT_PASSWORD\r"
expect "Press y|Y for Yes, any other key for No:"
send "y\r"
expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
send "0\r"
expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "n\r"
expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"
expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "n\r"
expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"
expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"
EOF
sudo expect ~/secure_our_mysql.sh >> $script_log_file 2>/dev/null
rm -v ~/secure_our_mysql.sh >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS] YOUR ROOT PASSWORD IS : $MYSQL_ROOT_PASSWORD"; >> $script_log_file 2>/dev/null
sudo bash -c "echo $MYSQL_ROOT_PASSWORD > /var/www/html/mysql"  >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";
fi

echo $green_color"CHANGING PHP FPM UPLOAD VALUES";
sudo sed -i 's/post_max_size = 8M/post_max_size = 1000M/g' /etc/php/7.4/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1000M/g' /etc/php/7.4/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.4/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/memory_limit = 128/memory_limit = 12800/g' /etc/php/7.4/fpm/php.ini >> $script_log_file 2>/dev/null
sudo service php7.4-fpm restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


if ! [ -x "$(command -v mysql)"  >> $script_log_file 2>/dev/null ]; then
echo $green_color"[MYSQL ALREADY INSTALLED!]";
echo $green_color"[######################################]";
fi

echo $no_color"PUSHING CRONJOBS";
(crontab -l 2>/dev/null; echo "################## START $domain ####################") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html/$domain && rm -rf ./.git/index.lock && git reset --hard HEAD && git clean -f -d && git pull origin master --allow-unrelated-histories") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html/$domain && php artisan queue:restart && php artisan queue:work >> /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html/$domain && php artisan schedule:run >> /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html/$domain && chmod -R 777 *") | crontab -
(crontab -l 2>/dev/null; echo "################## END $domain ####################") | crontab -
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"FINALIZE INSTALLING";
sudo apt-get autoremove -y >> $script_log_file 2>/dev/null
sudo apt-get autoclean -y >> $script_log_file 2>/dev/null
sudo apt-get update  >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $green_color"[MADE WITH LOVE BY Peter Ayoub PeterAyoub.me]";
echo $green_color"[####################]";

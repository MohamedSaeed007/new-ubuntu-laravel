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

echo $no_color"INSTALLING PHP 8.2";
sudo apt-get update  >> $script_log_file 2>/dev/null
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y >> $script_log_file 2>/dev/null
sudo add-apt-repository ppa:ondrej/php -y >> $script_log_file 2>/dev/null
sudo apt-get update  >> $script_log_file 2>/dev/null
sudo apt install php8.2 -y >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";


echo $no_color"INSTALLING PHP EXTENSIONS";
sudo apt install php8.2 openssl php8.2-fpm php8.2-common php8.2-curl php8.2-mbstring php8.2-mysql php8.2-xml php8.2-zip php8.2-gd php8.2-cli php8.2-xml php8.2-imagick php8.2-xml php8.2-intl php-mysql -y >> $script_log_file 2>/dev/null
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
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
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

echo $green_color"CHANGING PHP FPM UPLOAD VALUES";
sudo sed -i 's/post_max_size = 8M/post_max_size = 1000M/g' /etc/php/8.2/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1000M/g' /etc/php/8.2/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/8.2/fpm/php.ini >> $script_log_file 2>/dev/null
sudo sed -i 's/memory_limit = 128/memory_limit = 12800/g' /etc/php/8.2/fpm/php.ini >> $script_log_file 2>/dev/null
sudo service php8.2-fpm restart >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $no_color"FINALIZE INSTALLING";
sudo apt-get autoremove -y >> $script_log_file 2>/dev/null
sudo apt-get autoclean -y >> $script_log_file 2>/dev/null
sudo apt-get update  >> $script_log_file 2>/dev/null
echo $green_color"[SUCCESS]";
echo $green_color"[######################################]";

echo $green_color"[####################]";

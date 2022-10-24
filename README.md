# About

### install Important softwares on fresh Ubuntu instance

- [ ]  PREPAIRE INSTALLING
- [ ]  REMOVING APACHE
- [ ]  INSTALLING PHP 8.1
- [ ]  INSTALLING NGINX
- [ ]  OPEN NGINX PORTS
- [ ]  INSTALLING PHP EXTENSIONS
- [ ]  INSTALLING NPM
- [ ]  INSTALLING CERTBOT (SSL GENERATOR)
- [ ]  RESTARTING NGINX
- [ ]  CREATING NGINX FILE FOR [example.com](http://example.com/)
- [ ]  GENERATING SSL CERTIFICATE FOR [example.com](http://example.com/)
- [ ]  FINALIZE INSTALLING
- [ ]  RESTARTING NGINX

### How to Use

```php

wget https://raw.githubusercontent.com/peter-tharwat/new-ubuntu-laravel/master/script.sh ; sudo chmod +x script.sh ; ./script.sh -d example.com
# Replace example.com with your domain
```

### How To Debug LIVE

```php
tail -f script_log.log
```
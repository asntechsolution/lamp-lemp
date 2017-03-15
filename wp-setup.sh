#!/bin/bash -e

# Create MySQL database
read -p "Enter your MySQL root password: " rootpass
read -p "Database name: " dbname
read -p "Database username: " dbuser
read -p "Enter a password for user $dbuser: " userpass
echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';" | mysql -u root -p$rootpass
echo "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';" | mysql -u root -p$rootpass
echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
echo "New MySQL database is successfully created"
echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
echo "===================================================="
echo "AsnTechSolution is now installing WordPress for you."
echo "===================================================="
curl -O https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
cd wordpress
cp -rf . ..
cd ..
rm -R wordpress
cp wp-config-sample.php wp-config.php

perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$userpass/g" wp-config.php


perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

mkdir wp-content/uploads
chmod 775 wp-content/uploads
echo "Cleaning..."
rm latest.tar.gz

rm wp-setup.sh
echo "================================================="
echo "Congrats! Your Wordpress Installation is complete."
echo "================================================="
fi

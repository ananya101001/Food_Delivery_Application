
#!/bin/bash

# Make mountpath
sudo mkdir /data

# Mount device xvdh file system to created mountpath
sudo mount /dev/xvdf /data

# Run the script stored on dir, REQUIRES THE DEVICE TO BE FORMATTED, MOUNTED, AND THE FILE TO BE MOVED TO THE DIRECTORY
chmod 755 /data/install_apache.sh
sh /data/install_apache.sh

# Create the backend directory
mkdir -p /var/www/backend

# Create the index.html file
echo "<html><body><h1>Hello from backend</h1></body></html>" > /var/www/backend/index.html

# Set proper permissions
chown -R www-data:www-data /var/www/backend
chmod 644 /var/www/backend/index.html

# Configure Apache to serve the backend
cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/backend

    Alias "/backend" "/var/www/backend"
    <Directory "/var/www/backend">
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Restart Apache to apply changes
systemctl restart apache2
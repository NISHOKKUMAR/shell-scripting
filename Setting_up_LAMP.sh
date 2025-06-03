#!/bin/bash

# Exit on any error
set -e

# Updating system packages
echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Installing Apache
echo "Installing Apache web server..."
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
echo "Apache installed and running."

# Installing MySQL
echo "Installing MySQL database server..."
sudo apt install mysql-server -y

# Secure MySQL installation
echo "Securing MySQL installation..."
sudo mysql_secure_installation

sudo systemctl enable mysql
sudo systemctl start mysql
echo "MySQL installed and running."

# Installing PHP and necessary PHP modules
echo "Installing PHP and required modules..."
sudo apt install php libapache2-mod-php php-mysql -y

# Restart Apache to apply changes
sudo systemctl restart apache2
echo "PHP installed and Apache restarted."

# (Optional) Install phpMyAdmin
read -p "Do you want to install phpMyAdmin? (y/n): " install_phpmyadmin

if [ "$install_phpmyadmin" == "y" ]; then
    echo "Installing phpMyAdmin..."
    sudo apt install phpmyadmin -y

    # Enabling necessary PHP modules for phpMyAdmin
    sudo phpenmod mcrypt
    sudo phpenmod mbstring

    # Restarting Apache to apply changes
    sudo systemctl restart apache2
    echo "phpMyAdmin installed and Apache restarted."
else
    echo "Skipping phpMyAdmin installation."
fi

# Setting up firewall rules to allow web traffic
echo "Setting up firewall rules..."
sudo ufw allow in "Apache Full"

# Enable MySQL through the firewall if phpMyAdmin was installed
if [ "$install_phpmyadmin" == "y" ]; then
    sudo ufw allow in "MySQL"
fi

# Check status of services
echo "Checking status of Apache, MySQL services..."
sudo systemctl status apache2 --no-pager
sudo systemctl status mysql --no-pager

echo "LAMP stack setup completed successfully!"


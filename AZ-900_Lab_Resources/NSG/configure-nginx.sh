#!/bin/bash

# Update apt cache.
sudo apt update

# Install Nginx.
sudo apt install -y nginx

# Set the home page.
echo "<html><body><h2>Welcome to the Baltic Apprenticeships Azure Fundamentals! My name is $(hostname).</h2></body></html>" | sudo tee -a /var/www/html/index.html
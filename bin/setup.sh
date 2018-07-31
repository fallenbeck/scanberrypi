#!/bin/bash
# Installation script

# Configuration options
INSTALL_DIR=/opt/scanberrypi


### Here be dragons ###
echo "You need sudo rights to install this scripts"
sudo echo "Password acceppted"

echo "Installing software ..."
sudo apt -y install sane sane-utils gscan2pdf scanbd graphicsmagick-imagemagick-compat ocrmypdf ocrmypdf-doc ncftp

echo "Scanner(s) found:"
sudo scanimage -L

echo "Installing scripts ..."
sudo cp /etc/scanbd/scanbd.conf /etc/scanbd/scanbd.conf.orig
sudo cp $INSTALL_DIR/etc/scanbd.conf /etc/scanbd/scanbd.conf

echo "Enabling scanbd service ..."
sudo systemctl enable scanbd.service

echo "Restarting scanbd service ..."
sudo systemctl restart scanbd.service

echo "Finished installation. Happy scanning! :-)"
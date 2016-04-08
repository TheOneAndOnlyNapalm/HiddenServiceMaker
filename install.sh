#!/bin/bash
# Tor Hidden Service Installation Script
# By Napalm
# https://www.github.com/Napalm452
# http://hackforums.net/member.php?action=profile&uid=2471452
# https://keybase.io/napalm
clear

if [[ "$EUID" -ne 0 ]]; then
	echo "This script must be run in sudo" 1>&2
	exit 1
fi

if [ -f /etc/redhat-release ]; then
    echo "This script can currently only be used on Debian, Ubuntu or a Debian based operation system."
	exit 1
fi

if [[ -e /tor/hidden_service/ ]]; then
	echo "A Tor Hidden Service Is Already Installed And Running At: "
	cat /tor/hidden_service/hostname
	exit 1
else
	clear
	echo "Updating, and installing sudo & nano"
	
	# Updating, Upgrading, And Installing Sudo/Nano
	apt-get update && apt-get upgrade && apt-get install sudo nano
	echo "Step One Complete !"
	echo "Installing repositories, keys and tor"
	
	# Installs Repositiories.
	deb http://deb.torproject.org/torproject.org jessie main;deb-src http://deb.torproject.org/torproject.org jessie main
	
	# Installs keys
	gpg --keyserver keys.gnupg.net --recv 886DDD89
	gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
	
	# Updates again and installs tor
	apt-get update
	apt-get install tor deb.torproject.org-keyring
	echo "Step Two Complete !"
	
	# Config tor and echo hostname
	echo "Configuring Tor"
	rm /etc/tor/torrc
	echo "HiddenServiceDir /tor/hidden_service/
HiddenServicePort 80 127.0.0.1:80" > /etc/tor/torrc
	
	# Reload Tor
	service tor reload
	
	#Echo Hostname For Hidden Service
	echo "Your Hidden Service URL Is: "
	cat /tor/hidden_service/hostname
	echo "Step Three Complete !"
	
	echo "Installing and configuring Lighttpd"
	# Pretty self explainitory, it installs Lighttpd and php and makes a phpinfo page
	apt-get install lighttpd php5-cgi php5-mysql
	sudo lighttpd-enable-mod fastcgi
	sudo lighttpd-enable-mod fastcgi-php
	sudo service lighttpd force-reload
	echo "<?php phpinfo(); ?>" > /var/www/info.php
	
	#Disable Directory Viewing
	echo -e '\nserver.dir-listing          = "disable" ' > /etc/lighttpd/lighttpd.conf
	
	# Complete
	echo "Your Tor Hidden Service is complete and working!"
fi

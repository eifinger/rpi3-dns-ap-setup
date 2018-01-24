#!/bin/bash

echo "Updating the system"
sudo apt-get update
sudo apt-get upgrade -y
echo "Installing DNS and Access Point"
sudo apt-get install dnsmasq hostapd -y
echo "Configuring services"
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd
sudo echo "interface wlan0
    static ip_address=192.168.4.1/24" > /etc/dhcpcd.conf
sudo service dhcpcd restart
echo "Backing up DNS config to /etc/dnsmasq.conf.orig"
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo echo "interface=wlan0      # Use the require wireless interface - usually wlan0
  dhcp-range=192.168.0.2,192.168.0.20,255.255.255.0,24h" > /etc/dnsmasq.conf
sudo echo "interface=wlan0
driver=nl80211
ssid=RPIAP
hw_mode=g
channel=7
wmm_enabled=1
ieee80211n=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=123456789
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf
sudo sed -i 's/#DAEMON_CONF/DAEMON_CONF="/etc/hostapd/hostapd.conf"/' /etc/default/hostapd
sudo service hostapd start  
sudo service dnsmasq start  
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1' etc/sysctl.conf
sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
sudo iptables-save > /etc/iptables.ipv4.nat
sudo sed -i '/exit 0/i \
iptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local
echo "Finished"
echo "Access Point is set up with SSID <> and password <>"

#!/bin/bash
echo "---- DNS and AP setup script v1.0 ----"
echo "Author: Kevin Eifinger k.eifinger@googlemail.com"
echo "Source on https://github.com/eifinger/rpi3-dns-ap-setup"
echo "This code is subject to GNU General Public License v3.0"
echo "---- DNS and AP setup script v1.0 ----"
echo "Updating the system"
apt-get update
apt-get upgrade -y
echo "Installing DNS and Access Point"
apt-get install dnsmasq hostapd -y
echo "Configuring DNS and Access Point services"
systemctl stop dnsmasq
systemctl stop hostapd
echo "interface wlan0
    static ip_address=192.168.0.1/24" > /etc/dhcpcd.conf
service dhcpcd restart
echo "Backing up DNS config to /etc/dnsmasq.conf.orig"
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
echo "interface=wlan0      # Use the require wireless interface - usually wlan0
  dhcp-range=192.168.0.2,192.168.0.20,255.255.255.0,24h" > /etc/dnsmasq.conf
echo "Setting up Access Point"
echo "-----------------------------------------"
echo "Please provide the SSID and press <Enter>"
read ssid
echo "Please provide the password (at least 8 characters long) and press <Enter>"
read passwd
echo "interface=wlan0
driver=nl80211
ssid=$ssid
hw_mode=g
channel=7
wmm_enabled=1
ieee80211n=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$passwd
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf
sed -i 's:^#DAEMON_CONF="":DAEMON_CONF="/etc/hostapd/hostapd.conf":' /etc/default/hostapd
echo "Starting DNS and Access Point services"
service hostapd start
service dnsmasq start
echo "Enabling forwarding ipv4 traffic"
sed -i 's:^#net.ipv4.ip_forward=1:net.ipv4.ip_forward=1:' /etc/sysctl.conf
echo "Enabling routing"
iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
echo "Persisting iptables"
iptables-save > /etc/iptables.ipv4.nat
sed -i '/exit 0/aiptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local
echo "Finished"
echo "Access Point is set up with SSID $ssid and password $passwd"
echo "These can be adjusted in the file /etc/hostapd/hostapd.conf"
echo "To enable the new settings please reboot the system with 'sudo shutdown -r now'"

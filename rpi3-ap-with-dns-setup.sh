#!/bin/bash
echo "DNS and AP setup script v0.1"
echo "Updating the system"
apt-get update
apt-get upgrade -y
echo "Installing DNS and Access Point"
apt-get install dnsmasq hostapd -y
echo "Configuring services"
systemctl stop dnsmasq
systemctl stop hostapd
echo "interface wlan0
    static ip_address=192.168.4.1/24" > /etc/dhcpcd.conf
service dhcpcd restart
echo "Backing up DNS config to /etc/dnsmasq.conf.orig"
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
echo "interface=wlan0      # Use the require wireless interface - usually wlan0
  dhcp-range=192.168.0.2,192.168.0.20,255.255.255.0,24h" > /etc/dnsmasq.conf
echo "Setting up Access Point"
echo "Please provide the SSID and press <Enter>"
read ssid
echo "Please provide the password and press <Enter>"
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
sed -i 's:^#DAEMON_CONF:DAEMON_CONF="/etc/hostapd/hostapd.conf":' /etc/default/hostapd
service hostapd start  
service dnsmasq start  
sed -i 's:^#net.ipv4.ip_forward=1:net.ipv4.ip_forward=1:' etc/sysctl.conf
iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.ipv4.nat
sed -i '/exit 0/aiptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local
echo "Finished"
echo "Access Point is set up with SSID $ssid and password $passwd"

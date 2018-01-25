# rpi3-dns-ap-setup
This script installs a DNS using dnsmasq and sets up a WLAN Access Point.  
  
If an ethernet cable is connected, the Access Point is bridged to the wired network.
This means if your Raspberry has internet connection via Ethernet, all clients connected to the WLAN AP have internet too.
  
The Access Point configuration is proven to work with the Dell Edge Gateway 3001 running Ubuntu Core 16.04 as a client.
## Prerequisites
A fresh install of rasbian
Tested on 2017-11-29-raspbian-stretch-lite
## Usage
1. `git clone https://github.com/eifinger/rpi3-dns-ap-setup`  
or  
`wget https://raw.githubusercontent.com/eifinger/rpi3-dns-ap-setup/master/rpi3-ap-with-dns-setup.sh`
2. `chmod +x rpi3-ap-with-dns-setup.sh`
3. `sudo bash ./rpi3-ap-with-dns-setup.sh`
4. Enter SSID and password when prompted

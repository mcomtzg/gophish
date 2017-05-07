#!/bin/bash


#Get the servers externally facing IP and store as var & Grab the connected SSH client for ufw ruleset
var="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
var1="$(who am i --ips|awk '{print $5}')"


#Install GoLang and skip prompts & Set GoPath on system
echo -------------------------- Installing GoLang --------------------------
echo
apt-get -y install golang-go
export GOPATH=$HOME/GoWork
echo

#Go Get GoPhish From rfdevere build
echo ------------------------- Getting GoPhish ----------------------------
echo 
go get github.com/rfdevere/gophish
echo Done...
echo 

#Move into the project & Build
echo ------------------------- Building GoPhish ---------------------------
echo
cd ~/GoWork/src/github.com/rfdevere/gophish
go build
echo Done...
echo

#Replace the host IP in config.json from localhost 127.0.0.1 to external variable IP
echo --------------------------- Configuration -----------------------------
echo
echo The Server IP is $var this will now be changed in the config file.
#sed -i 's!127.0.0.1!0.0.0.0!g' ~/GoWork/src/github.com/rfdevere/gophish/config.json
sed -i 's/127.0.0.1/'$var'/gi' ~/GoWork/src/github.com/rfdevere/gophish/config.json
echo 

#Clearing ports 80/3333 incase anything was running... 
echo ---------------------- Clearing 80,3333/TCP --------------------------
echo 
fuser -k 80/tcp
fuser -k 3333/tcp
echo Done...
echo 

#Installing PostFix
echo --------------------- Installing Email Client -----------------------------
export DEBIAN_FRONTEND=noninteractive
apt-get install -y postfix
apt -y install postfix
echo

#Securing GoPhish
echo -------------------- Firewall Configuration ------------------------------
echo 'Curent Firewall Status:'
ufw status
echo
echo Your IP Address is assumed to be "($var1)"
echo 'Adding Firewall Rules...'
iptables -A INPUT -p tcp --dport 3333 -s "($var1)" -j ACCEPT
iptables -A INPUT -p tcp --dport 3333 -j DROP
sleep 2
echo 'The Following Rules Have Been Added:'
ufw show added
echo 'Activating Firewall...'
sudo ufw --force enable
echo 'Curent Firewall Status:'
ufw status
echo 

#Launch GoPhish
echo ------------------------ Launching GoPhish --------------------------
./gophish

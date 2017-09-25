#!/bin/bash

#curl -s https://raw.githubusercontent.com/rfdevere/gophish/master/install.sh | sudo bash

#Get the servers externally facing IP and store as var & Grab the connected SSH client for ufw ruleset
var="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"

#Update packages
apt-get update

#Install git if not already on server for go get command
apt-get -y install git 


#Install GoLang and skip prompts & Set GoPath on system
echo -------------------------- Installing GoLang --------------------------
echo
apt-get -y install golang-go
export GOPATH=$HOME/GoWork
echo

#Go Get GoPhish From rfdevere build
echo ------------------------- Getting GoPhish ----------------------------
echo 
go get github.com/gophish/gophish
echo Done...
echo 

#Move into the project & Build
echo ------------------------- Building GoPhish ---------------------------
echo
cd $HOME/GoWork/src/github.com/gophish/gophish
go build
echo Done...
echo

#Replace the host IP in config.json from localhost 127.0.0.1 to external variable IP
echo --------------------------- Configuration -----------------------------
echo
echo The Server IP is $var this will now be changed in the config file.
#sed -i 's!127.0.0.1!0.0.0.0!g' ~/GoWork/src/github.com/rfdevere/gophish/config.json
sed -i 's/127.0.0.1/'$var'/gi' ~/GoWork/src/github.com/gophish/gophish/config.json
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

#Launch GoPhish
echo ------------------------ Launching GoPhish --------------------------
./gophish

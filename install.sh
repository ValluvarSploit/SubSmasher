#!/usr/bin/env bash

if [[ $(id -u) != 0 ]]; then
    echo -e "\n[!] Install.sh requires root privileges"
    exit 0
fi

apt-get update
apt-get install golang -y
apt-get install gunzip -y
apt-get install zip -y
apt-get install git -y
apt-get install python3-pip

mkdir -p ./tools
cd tools/
git clone https://github.com/aboul3la/Sublist3r
cd Sublist3r
pip3 install -r requirements.txt
cd ../

git clone https://github.com/m8r0wn/subscraper
cd subscraper
python3 setup.py install
cd ../

mkdir -p assetfinder
cd assetfinder
wget https://github.com/tomnomnom/assetfinder/releases/download/v0.1.1/assetfinder-linux-amd64-0.1.1.tgz
gunzip -c assetfinder-linux-amd64-0.1.1.tgz |tar xvf -
chmod +x assetfinder
cd ../

mkdir -p subfinder 
cd subfinder
wget https://github.com/projectdiscovery/subfinder/releases/download/v2.4.5/subfinder_2.4.5_linux_amd64.tar.gz 
tar -xzvf subfinder_2.4.5_linux_amd64.tar.gz
chmod +x subfinder
cd ../

sudo snap install amass

mkdir -p jq
cd jq
wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 
mv jq-linux64 jq 
chmod +x jq
cd ../

mkdir -p findomain
cd findomain
wget https://github.com/Findomain/Findomain/releases/download/2.1.5/findomain-linux 
mv findomain-linux findomain
chmod +x findomain


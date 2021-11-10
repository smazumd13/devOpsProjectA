#!/bin/bash
sudo apt-get update
sudo apt install -y openjdk-11-jre-headless
sudo apt-get install -y docker*
sudo apt-get install -y maven
sudo apt update
sudo apt-get install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
sudo apt-get install -y python-properties
sudo apt install python-pip
sudo pip install ansible[azure]
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
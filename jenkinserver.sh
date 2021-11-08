#!/bin/bash
sudo apt-get update
sudo apt install -y openjdk-11-jre-headless
mkdir jenkins
cd jenkins
wget https://get.jenkins.io/war-stable/2.303.1/jenkins.war

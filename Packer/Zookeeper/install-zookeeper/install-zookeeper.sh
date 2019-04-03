#!/bin/bash

set -e

# Packages
sudo yum -y update
sudo yum -y install wget ca-certificates zip net-tools tar nmap-ncat

# Java Open JDK 8
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-linux-x64.rpm"
sudo yum -y localinstall jdk-8u152-linux-x64.rpm
rm jdk-8u152-linux-x64.rpm
java -version

# Disable RAM Swap - can set to 0 on certain Linux distro
sudo sysctl vm.swappiness=1
echo 'vm.swappiness=1' | sudo tee --append /etc/sysctl.conf

# Add hosts entries (mocking DNS) - put relevant IPs here
#echo "10.0.0.1 kafka1
#10.0.10.1 zookeeper1
#10.0.0.2 kafka2
#10.0.10.2 zookeeper2
#10.0.0.3 kafka3
#10.0.10.3 zookeeper3" | sudo tee --append /etc/hosts

cd /tmp
set -x
# sudo chmod +x ./store_ip.sh
set +x
# download Zookeeper and Kafka. Recommended is latest Kafka (0.10.2.1) and Scala 2.12
wget http://apache.mirror.digitalpacific.com.au/kafka/0.11.0.2/kafka_2.12-0.11.0.2.tgz
tar -xvzf kafka_2.12-0.11.0.2.tgz
rm kafka_2.12-0.11.0.2.tgz
sudo mkdir -p /opt/zookeeper
sudo mv kafka_2.12-0.11.0.2 /opt/zookeeper/kafka
sudo mv /tmp/install-zookeeper/zookeeper.properties /opt/zookeeper/kafka/config/zookeeper.properties
#cd /opt/zookeeper/kafka
# Zookeeper quickstart
#cat config/zookeeper.properties
#bin/zookeeper-server-start.sh config/zookeeper.properties
# binding to port 2181 -> you're good. Ctrl+C to exit

# Testing Zookeeper install
# Start Zookeeper in the background
#bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
#bin/zookeeper-shell.sh localhost:2181
#ls /
# demonstrate the use of a 4 letter word
#echo "ruok" | nc localhost 2181 ; echo

# Install Zookeeper boot scripts
#sudo nano /etc/init.d/zookeeper
sudo mv /tmp/install-zookeeper/zookeeper.sh /etc/init.d/zookeeper
sudo chmod +x /etc/init.d/zookeeper
sudo mkdir -p /var/log/zookeeper
#sudo chown root:root /etc/init.d/zookeeper

sudo chkconfig --add zookeeper
sudo chkconfig zookeeper on

# create data dictionary for zookeeper
sudo mkdir -p /data/zookeeper
sudo chown -R ec2-user:ec2-user /data/

# temporarily declare the server's identity
echo "1" > /data/zookeeper/myid

# start zookeeper
sudo service zookeeper start
# verify it's started
#nc -vz localhost 2181
#nc -w1 127.0.0.1 2181
#echo "ruok" | nc 127.0.0.1 2181 ; echo
# check the logs
#cat logs/zookeeper.out

#sudo rm -rf /tmp/*
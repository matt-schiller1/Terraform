#! /bin/bash

# Update/Upgrade VM
yum update -y
yum install wget -y

# Install Java 
yum install java-1.8.0-openjdk.x86_64 -y

# Create a directory named app and cd into the directory
mkdir /app && cd /app

# Download the latest nexus. 
wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/nexus-3.67.1-01-java8-unix.tar.gz

# Unzip
tar -xvf nexus.tar.gz

# Rename the untared file to nexus
mv nexus-3* nexus3

# Change the ownership of the nexus files and nexus data directory to nexus user.
chown -R ec2-user:ec2-user /app/nexus3
chown -R ec2-user:ec2-user /app/sonatype-work

# Open the Nexus configuration file 
cd /app/nexus3/bin
sudo sed -i 's/#run_as_user=""/run_as_user="ec2-user"/' nexus.rc

# Create the systemd service
cat <<EOF | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=ec2-user
Group=ec2-user
ExecStart=/app/nexus3/bin/nexus start
ExecStop=/app/nexus3/bin/nexus stop
User=ec2-user
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable the Nexus service to start at boot
sudo systemctl enable nexus.service

# Start the service
sudo systemctl start nexus.service

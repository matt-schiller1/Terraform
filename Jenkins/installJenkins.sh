#! /bin/bash

# Update
yum update –y

# Install Java
yum install java-17-amazon-corretto -y

# Download and Install Jenkins
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade
yum install jenkins -y

# Enable Jenkins with systemctl
systemctl enable jenkins

# Start Jenkins
systemctl start jenkins

#Install Git SCM
yum install git -y

# Enable service for jenkins
chkconfig jenkins on
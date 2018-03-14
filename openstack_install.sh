#!/bin/bash

if [ $(id -u) != 0 ]; then 
    echo 'Please use root user, must be root'
    exit
fi

function service_cleanup() {
# Cleanup for OpenStack
    printf '[*] Disable and removing postfix, firewalld, and NetworkManager.\n'
    systemctl stop postfix firewalld NetworkManager
    systemctl disable postfix firewalld NetworkManager
    systemctl mask NetworkManager
    yum remove postfix NetworkManager NetworkManager-libnm -y
}

function disable_selinux() {
    # Disable SELinux
    printf '[*] Disabling SELinux.\n'
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
}

function install_ntpupdate() {
    # Install ntpupdate
    printf '[*] Installing ntpupdate.\n'
    yum install ntpdate -y
}

function set_hostname() {
    # Set hostname
    printf '[*] Setting hostname, provide hostname:\n'
    read -r -p ">>> " set_hostname_variable
    hostnamectl set-hostname $set_hostname_variable
}

function install_openstack() {
    # Install OpenStack Pike
    printf '[*] Installing OpenStack Pike packages.\n'
    yum install centos-release-openstack-pike -y
    printf '[*] Updating rpm libraries and installing packstack.\n'
    yum update -y
    yum install openstack-packstack -y
}

function configure_packstack_file() {
    # Packstack configuration
    printf '[*] Configuring packstack file.\n'
    packstack --gen-answer-file=/root/$(date +"%d.%m.%y").conf
    printf '[*] Provide a password for admin:\n'
    read -r -p '>>> ' admin_password
    printf '[*] Provide a password for MariaDB:\n'
    read -r -p '>>> ' mariadb_password
    sed -i 's/CONFIG_NTP_SERVERS=/CONFIG_NTP_SERVERS=0.ro.pool.ntp.org/g' /root/$(date +"%d.%m.%y").conf

    sed -i 's/CONFIG_PROVISION_DEMO=y/CONFIG_PROVISION_DEMO=n/g' /root/$(date +"%d.%m.%y").conf

    sed -i 's/CONFIG_HORIZON_SSL=n/CONFIG_HORIZON_SSL=y/g' /root/$(date +"%d.%m.%y").conf
    
    sed -i "/CONFIG_KEYSTONE_ADMIN_PW=/c\CONFIG_KEYSTONE_ADMIN_PW=$admin_password" /root/$(date +"%d.%m.%y").conf

    sed -i "/CONFIG_MARIADB_PW=/c\CONFIG_MARIADB_PW=$mariadb_password" /root/$(date +"%d.%m.%y").conf
}

function configure_ssh() {
    # Configure SSH
    printf '[*] Configuring SSH.\n'
    sed -i 's/#PermitRootLogin\ yes/PermitRootLogin\ yes/g' /etc/ssh/sshd_config
    systemctl restart sshd
}

function complete_packstack() {
    # Configure openstack
    printf '[*] Packstack the answer file to build our OpenStack environment.\n'
    packstack --answer-file /root/$(date +"%d.%m.%y").conf
}


#################################
#    Functions that will run    #
#################################

service_cleanup
disable_selinux
install_ntpupdate
set_hostname
install_openstack
configure_packstack_file
complete_packstack

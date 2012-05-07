#!/bin/bash
#                                                                              #
#  GFS2CLVM Datastore and Transfer Manager installation script                 #
#                                                                              #
#  To be run on each Hypervisor server as root                                 #
#                                                                              #
#  This script will install KVM,Libvirt,Ruby and configure                     #
#  as a host, ready to go.  Will need SSH keys propagated and                  #
#  cluster/storage configured						       #
################################################################################

################################################################################
# Prepare Environment
################################################################################

yum -y install qemu-kvm libvirt ruby
sed -e '/requiretty/d' /etc/sudoers > tempsudo
mv tempsudo /etc/sudoers
chmod 0440 /etc/sudoers
groupadd -g 1001 oneadmin
useradd -u 1001 -d /var/lib/one -g oneadmin oneadmin
echo "Set Password for 'oneadmin' user:"
passwd oneadmin
sed -i -e 's,^#dynamic_ownership = 1,dynamic_ownership = 0,' /etc/libvirt/qemu.conf
sed -i -e 's,^#user = "root",user = "oneadmin",' /etc/libvirt/qemu.conf
sed -i -e 's,^#group = "root",group = "oneadmin",' /etc/libvirt/qemu.conf
sed -i -e 's,^#listen_tcp = 1,listen_tcp = 1,' /etc/libvirt/libvirtd.conf
mkdir /var/lib/one/.ssh
chmod 700 /var/lib/one/.ssh
echo "Host *" > /var/lib/one/.ssh/config
echo "StrictHostKeyChecking no" >> /var/lib/one/.ssh/config
chmod 600 /var/lib/one/.ssh/config
chown -R oneadmin:oneadmin /var/lib/one/.ssh

################################################################################
# Copy files to destination locations
################################################################################

cp -rf ./etc-polkit-1-localauthority-50-local.d/* /etc/polkit-1/localauthority/50-local.d/
cp -rf ./etc-udev-rules-d/* /etc/udev/rules.d/
cp -rf ./HYPERVISORS-etc-sudoers-d/oneadmin-lvm /etc/sudoers.d
chmod 0440 /etc/sudoers.d/oneadmin-lvm
mkdir /var/lib/one/uploads
chown oneadmin:oneadmin /var/lib/one/uploads


################################################################################
# OpenNebula looks for KVM binary in /usr/bin/kvm, need to create link
################################################################################

ln -s /usr/libexec/qemu-kvm /usr/bin/kvm
service libvirtd start
clear
echo "Be sure to propagate keys from the OpenNebula management server by running the 'ssh-copy-id' script as 'oneadmin'!!!!"
echo "."
echo ".."
echo "..."
echo "....Installation complete"

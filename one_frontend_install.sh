#!/bin/bash
#                                                                              #
#  GFS2CLVM Datastore and Transfer Manager installation script                 #
#                                                                              #
#  To be run on the OpenNebula FrontEnd server as root                         #
#                                                                              #
################################################################################

################################################################################
# Prepare Environment
################################################################################

sed -e '/requiretty/d' /etc/sudoers > tempsudo
mv tempsudo /etc/sudoers
chmod 0440 /etc/sudoers
mkdir /var/lib/one/remotes/datastore/gfs2clvm
mkdir /var/lib/one/remotes/tm/gfs2clvm


################################################################################
# Copy files to destination locations
################################################################################

cp -rf ./etc-one/* /etc/one/
cp -rf ./etc-init.d/* /etc/init.d/
chmod +x /etc/init.d/oned
chmod +x /etc/init.d/oneacctd
chmod +x /etc/init.d/onesunstone
cp -rf ./etc-polkit-1-localauthority-50-local.d/* /etc/polkit-1/localauthority/50-local.d/
cp -rf ./etc-udev-rules-d/* /etc/udev/rules.d/
cp -rf ./usr-lib-one-sunstone-public-js-plugins/* /usr/lib/one/sunstone/public/js/plugins/
cp -rf ./var-lib-one-remotes-datastore-gfs2clvm/* /var/lib/one/remotes/datastore/gfs2clvm/
cp -rf ./var-lib-one-remotes-tm-gfs2clvm/* /var/lib/one/remotes/tm/gfs2clvm/
cp -rf ./OPENNEBULAFE-etc-sudoers-d/oneadmin-scp /etc/sudoers.d
chmod 0440 /etc/sudoers.d/oneadmin-scp
chown -R oneadmin:oneadmin /var/lib/one
chmod -R +x /var/lib/one/remotes/datastore/gfs2clvm
chmod -R +x /var/lib/one/remotes/tm/gfs2clvm
chkconfig oned on
chkconfig oneacctd on
chkconfig onesunstone on


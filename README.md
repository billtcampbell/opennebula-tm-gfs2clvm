"GFS2CLVM" TM/Datastore Driver for OpenNebula 3.4
Modified by Bill Campbell
Contact: bill.t.campbell@gmail.com

## MODIFICATIONS

This is a fork of Jan Horacek's excellent "gfs2clvm" TM driver for OpenNebula.  With the release of OpenNebula 3.4, additional capability was presented
that caused his driver to no longer function.  This fork restores functionality, along with the following enhancements:

* Multiple Datastore/Cluster/Volume Group Support
	
	-- Allows the creation of multiple Volume Groups and Datastores, so images can be segmented accordingly, or to match whatever storage configuration 		   is needed

	-- Volume Groups can be named any name (no longer need the vg_ prefix).  This is a udev parameter.

	-- CONFIGURATION ITEM: When creating Volume Groups/Datastores, ensure they are named IDENTICALLY.

* Image conversion handled differently

	-- Jan's driver did a raw conversion using the 'dd' utility.  This updated driver uses 'qemu-img convert -O host_device' to copy source images to 		   logical volumes.  This allows the GFS2 image store to hold smaller qcow2/vmdk/vdi images (basically any image qemu-img supports converting), and 		   enables additional functionality (see next item).

* Image upload from Sunstone

	-- One of the new features of OpenNebula 3.4 is the ability to upload images directly from any client machine through the web interface.  The 		   driver has been modified to take advantage of this functionality.  Be sure that the OpenNebula frontend has enough space to temporarily hold the image file that's being uploaded (hence the idea of using smaller base images like qcow2, vdi, etc.)

* Datastore creation in Sunstone

	-- You can create a GFS2CLVM and select the GFS2CLVM driver when creating a datastore in Sunstone

* Installation Scripts

	-- Quick installation scripts for both the OpenNebula front-end and hypervisors (currently only CentOS/RHEL 6.x, will look into developing for Ubuntu/Debian derivatives if time permits)

* Persistent/Non-Persistent snapshots of suspended virtual machine disks

	-- In previous logic, it was possible to create a copy of a running virtual machine.  Without proper snapshot/protection mechanisms, this can be dangerous.  Added some logic to determine state of the virtual machine prior to copy and will error if virtual machine is running.
	
	-- Can create the clone of the suspended VM disk in any configured GFS2CLVM datastore.
	
	-- As such, the 'lvm://{VMID}/{DISKID}' path directive when creating an image has been changed to 'snapshot://{VMID}/{DISKID}' to be more descriptive with the source action.

* Clone of existing image in datastore

	-- This has been modified to allow clone of image from one datastore to another datastore (volume group)
	
	-- Additional logic was added to check if a persistent image is currently in use and the VM is running.
	
	-- As such, the 'vol://{IMAGEID}' path directive when cloning an image has been changed to 'image://{IMAGEID}' to be more descriptive with the source action.	 


## INSTALLATION

You can install the driver for both the hypervisor and front-end by running the included installation scripts.  

---Prerequisites for Front-End:  OpenNebula installed and initially configured

---Prerequisites for Hypervisors:  Hypervisor (KVM) and Libvirt installed

* It's probably not a bad idea to restart services or reboot each machine after installation to ensure proper configurations are in place (particularly the Hypervisor hosts)


## MANUAL INSTALLATION

Installation is the same as Jan's below, putting the appropriate files into the appropriate directories as labeled.  Be sure to run the following if running on a CentOS/RHEL based system:

* disabled dynamic ownership

    sed -i -e 's,^#dynamic_ownership = 1,dynamic_ownership = 0,' /etc/libvirt/qemu.conf

* virtual machines running by oneadmin/oneadmin, not root or other user

    sed -i -e 's,^#user = "root",user = "oneadmin",' /etc/libvirt/qemu.conf

    sed -i -e 's,^#group = "root",group = "oneadmin",' /etc/libvirt/qemu.conf


## CURRENT STATE

The following functions and their status have been tested on CentOS 6.2 x64, using KVM as the hypervisor, and any bugs/quirks noted:

* Instantiate									OK
* Resubmit							 			OK
* Restart										OK
* Reboot										NOT TESTED 

	(Getting JSON error when attempting to reboot, possibly my QEMU/Testing environment? CentOS 6.2)

* LiveMigrate						 			OK
* Suspend							 			OK
* Migrate							 			OK
* Stop							 				OK
* Resume							 			OK
* Cancel							 			OK
* Delete							 			OK 
* SaveAs								 		OK
* Shutdown										OK
* Snapshot non-persistent Suspended machine		OK
* Snapshot persistent Suspended machine			OK
* Snapshot non-persistent Running machine		OK
* Snapshot persistent Running machine			OK
* Import ttylinux from file 					NOT TESTED
* Create new Datablock volume 					OK
* Persistence 									OK
* Clone existing image						 	OK

-- The only real configuration item to remember that differs from Jan's original documentation is the ensure the volume groups and datastores are named identically.  The scripts use the datastore name as the volume group name.


I'm definitely not perfect, so some (or all) parts of this could be buggy/messy, but testing so far has been very positive.  I welcome all suggestions/modifications/etc.

## JAN'S ORIGINAL DOCUMENTATION BELOW


"gfs2clvm" Transfer Manager Driver for OpenNebula

## DESCRIPTION

The **gfs2clvm** transfer manager driver provides the needed functionality
for running OpenNebula on SAN storage with these premises:

* Virtual machines runing from Clustered LVM (persistnet and nonpersistent running vms, for SOURCE in templates)

* OS template images stored on GFS2 shared storage (bootable isos, for PATH in image template )

* Management node connected to the virtualisation cluster via SSH only

Other nice featurs

* Virtual machines (kvm processes) in the desired configuration are running
  under unprivileged "oneadmin" user

* Logical volumes created for virtual machines owned by "oneadmin" user, so the
  commonly required sudo for "dd" command in suoers is not needed

* copy/snapshot/clone of machine in SUSPENDED state
  by using lvm://{{VMID}}/{{DISKID}} as source

* copy/snapshot/clone of any volume by its ID, useful for persistent OS creation from saved template OS image
  by using vol://{{VOLID}} as source

Known drawbacks

* Still requires selinux in persmissive mode

* targeted at core IT staff, no acl/permissions when using lvm: and vol: volume sources

## STORAGE LOGIC EXPLAINED

The GFS2 volume in one of the LV is for /var/lib/one on worker nodes,
context.sh contextualisation isos, vm checkpoints, deployment.X and
disk.X symlinks are here. All the files for oned are on the management
node, in /var/lib/one. This storage is NOT shared betwen management
node and worker nodes.

All the images created dynamicaly by opennebula are placed in clvm.

So in the VG, there is

* LV for gfs2

* LVs "lv-one-XXX-X" for nonpresistent, dynamicaly created volumes - these
  volumes are lost when vm is shutdown/deleted/redeployed

* LVs "lv-oneimg-XXXXXXXXXXX for volumes created by opennebula (by saveas,
  cloning, import etc. they replacement of "hash-like" named files in
  /var/lib/one/images)

## INSTALLATION

Files are divided into subdirectories representing destination locations

* etc-one 					/etc/one/ 			(configuration)
* etc-sudoers-d 				/etc/sudoers.d/			(sudo rules)
* etc-udev-rules-d 				/etc/udev/rules.d/		(lvm lv ownership)
* usr-lib-one-tm_commands 			/usr/lib/one/tm_commands/	(tm driver)
* var-lib-one-remotes-image-fs 			/var/lib/one/remotes/image/fs/  (im driver)
* etc-polkit-1-localauthority-50-local.d 	/etc/polkit-1/localauthority/50-local.d/

Other configuration changes

* disabled dynamic ownership

    sed -i -e 's,^#dynamic_ownership = 1,dynamic_ownership = 0,' /etc/libvirt/qemu.conf

* virtual machines running by oneadmin/oneadmin, not root or other user

    sed -i -e 's,^#user = "root",user = "oneadmin",' /etc/libvirt/qemu.conf
    sed -i -e 's,^#group = "root",group = "oneadmin",' /etc/libvirt/qemu.conf


## CURRENT STATE

* instantiate			OK
* resubmit 			OK

* reboot 			OK

* livemigrate 			OK

* suspend 			OK

* migrate 			OK
* stop 				OK
* resume 			OK

* cancel 			OK
* shutdown 			OK
* delete 			OK
* saveas + shutdown 		OK (custom remotes)

* snapshot suspended machine 	OK
* import ttylinux from file 	OK
* create new datablock volume 	OK

* persistence 			OK

* new OS image from other img 	OK

Everything tested on EL6x (as of 2012-03-02, CentOS 6.2)


## ABOUT OPENNEBULA

OpenNebula is an open-source project aimed at building the industry standard
open source cloud computing tool to manage the complexity and heterogeneity of
distributed data center infrastructures.

http://opennebula.org

## AUTHOR

gfs2clvm is composed from original drivers (namely lvm and shared) by
Jan Horacek for Et netera

Contact:
 private: jahor@jhr.cz

## LICENSE

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



# centos7_kickstart

Make sure your kickstart file is in the /root/kickstart/ directory, then run 
the following from the command line:

virt-install --name=HOST-NAME-HERE \
--ram 8192 \
--disk path=/var/lib/libvirt/images/openstack-dashboard.img,size=60 \
--vcpus 4 \
--os-type=linux \
--os-variant=rhel7.3 \
--network bridge:br0 \
--nographics \
--location http://mirror.centos.org/centos/7/os/x86_64/ \
--initrd-inject=/root/kickstart/ks.cfg \
--extra-args="ks=file:/ks.cfg console=ttyS0"

Make sure to change HOST-NAME-HERE to the hostname you want for this new 
Linux instance.


For Openstack, a single node is currently supported.
Run the openstack_install.sh script in the /root/ directory.

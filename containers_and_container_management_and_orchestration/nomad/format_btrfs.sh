mkdir -p /data
pvcreate /dev/sdb
vgcreate VolGroupData /dev/sdb
lvcreate -l 100%VG -n Data VolGroupData
mkfs.btrfs /dev/VolGroupData/Data
echo "/dev/VolGroupData/Data /data   btrfs  noatime,nobarrier 1 2" >> /etc/fstab
mount /data
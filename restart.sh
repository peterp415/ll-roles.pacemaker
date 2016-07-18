echo 'y'| vagrant destroy
VBoxManage hostonlyif remove vboxnet0 && VBoxManage hostonlyif remove vboxnet1

sudo crm_mon -1

sudo crm configure property stonith-enabled=false
sudo crm configure property migration-threshold=1
sudo crm configure primitive dummy0 ocf:pacemaker:Dummy op monitor interval=20s

sudo crm_mon -1

sudo crm_resource --resource dummy0 --locate
resource dummy0 is running on: dangerzone1 

sudo crm_resource --quiet --resource dummy0 --move
sudo crm_resource --resource dummy0 --locate
resource dummy0 is running on: dangerzone2 

sudo crm_resource --resource dummy0 --force-stop

sudo  crm_resource --resource dummy0 --force-start
Operation start for dummy0 (ocf:pacemaker:Dummy) returned 0
 >  stderr: DEBUG: dummy0 start : 0
vagrant@dangerzone0:~$ sudo crm_resource --resource dummy0 --force-check
Operation monitor for dummy0 (ocf:pacemaker:Dummy) returned 0
 >  stderr: DEBUG: dummy0 monitor : 0

sudo crm_mon -1


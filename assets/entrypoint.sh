#!bin/bash

export IPADDR=$IPADDR

for iso in `find /iso -name '*iso' -type f`; do
	FILENAME=`basename $iso | sed 's/[_]/-/'`
	echo "<target example.org:$FILENAME>"         >> /etc/tgt/targets.conf
	echo "  <backing-store /iso/`basename $iso`>" >> /etc/tgt/targets.conf
        echo "    removable 1"                        >> /etc/tgt/targets.conf
	echo "    readonly  1"                        >> /etc/tgt/targets.conf
	echo "  </backing-store>"                     >> /etc/tgt/targets.conf
        echo "</target>"                              >> /etc/tgt/targets.conf
done

echo "APPEND dhcp && chain http://$IPADDR/" >> /srv/tftp/pxelinux.cfg/default

/usr/sbin/in.tftpd --listen -L --address 0.0.0.0:69 --secure -vvv /srv/tftp& 

tgtd -f & 
sleep 5;\
      	/usr/sbin/tgtadm --op update --mode sys --name State -v offline;\
	/usr/sbin/tgt-admin -e -c /etc/tgt/targets.conf;\
       	/usr/sbin/tgtadm --op update --mode sys --name State -v ready&

python3 /init.py

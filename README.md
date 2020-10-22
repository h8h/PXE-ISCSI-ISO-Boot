# (i)PXE ISCSI ISO Boot - Load various iso files

Motivation
----------
For laboratory and test purposes it often requires different operating systems and live disks. So I needed a tool that would simply provide ISO files on a network boot.


I tested various things, but often ISO - files had to be unpacked and kernel parameters had to be transferred to the PXE config.


With a certain number of ISOs the effort can become unmanageable.

Then I discovered sanboot and http. Unfortunately the range requests in the HTTP header do not work for ISO files larger than 4GB. At least it was not possible to get Kali Live Boot Image to live boot :-(.

I found out that iscsi can also include iso files. This works so easy that I made a docker container out of it, in which it is possible to place ISO files, that's it.

build it:
--------
`git clone github.com/h8h/PXE-ISCSI-ISO-Boot`

`cd PXE-ISCSI-ISO-Boot/`

modify at least the ip address and point it to your docker host's external ip address:

* `vi assets/boot.ipxe` in line 3

* `vi assets/init.py` in line 29

`docker build -t ipxeisoboot .`

run it:
-------

Point your DHCP - Server options (esp. next-server and (tftp)bootfile) to the docker host's external ip address and to the bootfile: `pxelinux.0`.

Then run docker:

`docker run -d --name ipxeboot --restart always -p 69:69/udp -p 80:80 -p 3260:3260 -v /iso:/iso ipxeisoboot:latest`

use it:
-------

Now place iso files in `/iso` on your local machine. Recreate (remove + run) the container again to create the new configurations.

screenshot it:
----------
![LiveBoot](/example.png?raw=true "Live ISO Boot")

license it
----------
see LICENSE - file

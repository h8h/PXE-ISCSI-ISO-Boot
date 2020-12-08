# (i)PXE ISCSI ISO Boot - Load various iso files

The current state is: ALPHA

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


edit `docker-compose.yml` 


`docker-compose up --build -d`


run it:
-------

Point your DHCP - Server options (esp. next-server and (tftp)bootfile) to the docker host's external ip address and to the bootfile: `pxelinux.0`.

Then run docker:


`docker-compose up --build -d`


or


`docker run -d --name ipxeboot --restart always -p 69:69/udp -p 80:80 -p 3260:3260 -v /iso:/iso ipxeisoboot:latest`

use it:
-------

Now place iso files in `/iso` on your local machine. Recreate (remove + run) the container again to create the new configurations.

develop it:
------------
First "run it"


`docker cp ipxeboot:/srv/tftp .`


`qemu-system-x86_64 -m 1024 -boot n -net nic -net user,tftp=tftp,bootfile=pxelinux.0`


how it works:
-------------
1. Your DHCP Server tells the PXE Client to load a `pxelinux.0` at your docker host's external ip address.
2. The PXE Client calls tftp://pxelinux.0 and receives the file and loads it into memory.
3. This boots up a PXE Bootloader which tells where the ipxe KERNEL (`ipxe.lkrn`) is (see `assets/pxelinux.cfg/default`).
4. The PXE Bootloader calls tftp://ipxe.lkrn and loads it into memory. Now the PXE client is an ipxe client.
5. The ipxe client has an embedded script (see `assets/boot.ipxe`) and runs it. 
6. The ipxe client runs dhcp.
7. The ipxe client calls http://x.x.x.x/
8. This triggers the small python3 web server which is already packed into the docker image.
9. The web server returns a list of all available ISO files in the folder `/iso`, see below.
10. Now the user choose one of the items of the ipxe boot loader.
11. Once chosen a request is made (`sanboot`) to the iscsi target (also packed in the docker image).
12. The iscsi hands over block by block the iso file. 
13. The system gets loaded.

You can shorten the path (2-4) if you already have ipxe clients. For that point your DHCP to the bootfile: `undionly.kpxe`

Wishlist:
--------
* A web interface to upload iso files to
* A central ip address configuration
* SSL support (Trusted CA)
* UEFI (I don't need it right now. Please file up a issue)

screenshot it:
----------
![LiveBoot](/example.png?raw=true "Live ISO Boot")

license it
----------
see LICENSE - file

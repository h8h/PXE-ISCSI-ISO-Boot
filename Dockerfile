FROM debian:buster-slim AS ipxe

RUN apt-get update && apt-get install -y git build-essential liblzma-dev pxelinux syslinux-common


RUN git clone git://git.ipxe.org/ipxe.git &&\
    cd ipxe/src &&\
    make bin/undionly.kpxe &&\
    make bin/ipxe.lkrn

FROM debian:buster-slim 

COPY --from=ipxe ipxe/src/bin/undionly.kpxe /srv/tftp/
COPY --from=ipxe /usr/lib/syslinux/modules/bios/* /srv/tftp/
COPY --from=ipxe /usr/lib/PXELINUX/pxelinux.0 /srv/tftp 
COPY --from=ipxe ipxe/src/bin/ipxe.lkrn /srv/tftp/
COPY assets/pxelinux.cfg/default /srv/tftp/pxelinux.cfg/
COPY assets/init.py /

RUN apt-get update && apt-get install -y tgt tftpd-hpa python3 tini

EXPOSE 69/udp
EXPOSE 80/tcp
EXPOSE 3260/tcp

ADD assets/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]

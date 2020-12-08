import re
import http.server
from http.server import SimpleHTTPRequestHandler
import socketserver
from string import Template
import os

BOOTLOADER = Template("""#!ipxe
echo Boot menu
menu ISO Boot menu

$items

choose os && goto $${os}

$sanboots

""")


class ipxe (SimpleHTTPRequestHandler):

        def do_GET(self):
                with open ("/etc/tgt/targets.conf", "r") as f:
                        targets = re.findall("<target example.org:([\w\.\-]+)>", f.read())

                items = []
                sanboots = []
                ipaddr = os.getenv("IPADDR",'192.168.1.2')
                for target in targets:
                        items.append("item {} {}".format(target,target))
                        sanboots.append(":{}\nset root-path iscsi:{}:::1:example.org:{}\nsanboot --drive 0x80 -k ${{root-path}}".format(target, ipaddr, target))

                BOOTLOADERMSG = BOOTLOADER.safe_substitute(items="\n".join(items),sanboots="\n\n".join(sanboots)).encode()
                self.send_response(200)
                self.send_header("Content-type", "text/plain")
                self.send_header("Content-length", len(BOOTLOADERMSG))
                self.end_headers()
                self.wfile.write(BOOTLOADERMSG)


PORT = 80

with socketserver.TCPServer(("", PORT), ipxe) as httpd:
    print("serving at port", PORT)
    try:
            httpd.serve_forever()
    except:
            pass

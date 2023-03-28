
# from pprint import pprint
import plistlib


from plistlib import load as pload
from plistlib import dump as pdump
# from plistlib import FMT_XML
# from plistlib import FMT_BINARY
from json import loads as jloads


def update_plist(path: str, keys: str = None):
    plist_bytes: bytes
    with open(path, 'rb') as f:
        #plist_bytes = f.read()
        plist = pload(f, fmt=None)

    #plist: dict = ploads(bytes(plist_bytes),fmt=FMT_XML)
    
    if keys:
        _keys = jloads(keys)
        plist.update(_keys)


        #_dump = pdumps(plist,fmt=FMT_XML)
        with open(path, 'wb') as f:
            #f.write(_dump)
            pdump(plist,f, fmt=None)


#!/usr/bin/env python3
import sys
from warcio.archiveiterator import ArchiveIterator

for warcname in sys.argv[1:]:
  with open(warcname, 'rb') as stream:
    for record in ArchiveIterator(stream):
      print(record.rec_headers.get_header('WARC-Target-URI'))


#!/usr/bin/env python3
import os
import sys
import jsonlines

with jsonlines.open(sys.argv[1]) as pages:
  pages.read() #First entry is not a page
  for page in pages:
    print(page['url'])
    #title = page['title']
    #if re.match('[1-5]\d\d\D', title): #possible http error code (re.match matches at start of string)
    #  codes.add(title)
    #  urls.add(page['url'])


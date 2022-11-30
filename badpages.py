#!/usr/bin/env python3

import os
import re
import ast
import sys
import yaml
import argparse
import jsonlines

parser = argparse.ArgumentParser(description = '''
Re-crawl pages that produced an HTTP error.

Usage example:
./badpages crawls/collections/capture-2022-04-28T16-31-14 -c sb.yaml -e sb.log

Or to re-run the crawl for the failed pages in one step:
./badpages crawls/collections/capture-2022-04-28T16-31-14 -c sb.yaml -e sb.log | docker run -i -v $PWD/crawls:/crawls/ webrecorder/browsertrix-crawler:0.5.1 crawl --config stdin --collection capture-2022-04-28T16-31-14
''', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('crawldir', help='Top-level directory of the browsertrix crawl')
parser.add_argument('--overrides', '-o', help='Comma-separated list of key:value pairs')
parser.add_argument('--config', '-c', help='Config file that defined the crawl')
parser.add_argument('--log', '-l', help='Error log from the crawl')
args = parser.parse_args()

urls = set()
codes = set()
with jsonlines.open(os.path.join(args.crawldir, 'pages', 'pages.jsonl')) as pages:
  for page in pages:
    title = page['title']
    if re.match('[1-5]\d\d\D', title): #possible http error code (re.match matches at start of string)
      codes.add(title)
      urls.add(page['url'])

if args.log:
  with open(args.log, 'r') as f:
    for number, line in enumerate([x.strip() for x in f], start = 1):
      m = re.match('ERROR: (https?://[^:]+): *(.*)', line)
      if m:
        codes.add(m[2])
        urls.add(m[1])
        continue
      m = re.match('Page Load Failed: (https?:[^,]+), *(.*)', line)
      if m:
        codes.add(m[2])
        urls.add(m[1])
        continue
      m = re.search('.*\berror\b.*', line, re.IGNORECASE)
      if m and not line == 'Error: Execution context was destroyed, most likely because of a navigation.':
        raise Exception(f'Uncaught potential error "{m[0][:-1]}" at {args.log}:{number}: {line}')

if len(codes):
  print('All titles/errors encountered\n' + '-----------------------------\n' + '\n'.join(sorted(codes)), file = sys.stderr)
else:
  print('No errors detected')

if not args.config: sys.exit(0)

#Generate the crawl config
with open(args.config, 'r') as f:
  config = yaml.safe_load(f)
config['seeds'] = [{'url': x} for x in urls]

if args.overrides:
  for k, v in [x.split(':') for x in args.overrides.split(',')]: #should not be any spaces in here, due to the nature of CLIs
    if   v == 'true':  config[k] = True
    elif v == 'false': config[k] = False
    else:              config[k] = ast.literal_eval(v)

print(file = sys.stderr)
print(yaml.dump(config))

print(f'''{len(urls)} pages to retry.
To run:
{" ".join(sys.argv)} | docker run -i -v {os.path.realpath(args.crawldir[0:args.crawldir.find("/collections/")])}:/crawls/ webrecorder/browsertrix-crawler:0.5.1 crawl --config stdin --collection {os.path.basename(args.crawldir)} 2>&1 | tee {args.log + "_" if args.log else args.config[:args.config.rfind(".")] + ".log"}
''', file = sys.stderr)

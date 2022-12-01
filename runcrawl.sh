#!/bin/bash

cat <<EOF
Usage: $0 config_file [workers]
For example: $0 configs/scarlets_and_blues.yaml 8
Tweak [workers] for your system or leave unset.

This script assumes that configs are screencasting
to port 9000. You may be able to monitor the crawl
at http://localhost:9000.

EOF
config="`basename $1 .yaml`"
dir="logs/$config"
log="${dir}/${config}.log"
out="${dir}/${config}.out"
err="${dir}/${config}.err"
mkdir -p "$dir"
cat > "$log" <<EOF
Command: $0 $@
Git remote:
`git remote -v`

Git revision: `git rev-parse HEAD`
Git status:
`git stat`

Docker: `docker --version`
LSB:
`cat /etc/lsb-release`

Image:
`docker image inspect webrecorder/browsertrix-crawler:latest`
EOF
cat "$1" | docker run -e CHROME_FLAGS='--incognito' -p 9000:9000 -i -v $PWD/crawls:/crawls/ webrecorder/browsertrix-crawler:latest crawl --config stdin ${2:+--workers $2} 2>"$err" | tee "$out"


cat <<EOF

Can e.g. use https://replayweb.page/ to view
resulting crawls/collections/*/*.wacz files.
At time of writing, this page works locally i.e.
your files do not get uploaded anywhere.

Alternatively, you could follow the steps at
https://github.com/webrecorder/browsertrix-crawler#viewing-crawled-data-with-pywb
to view the result.

To package up logs and archive:
./package.sh `echo ${1%.yaml} | sed 's#^config/##'`

You may need to do this to run package.sh:
sudo chown -R "$USER" crawls
EOF
exit 0

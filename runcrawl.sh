#!/bin/bash

cat <<EOF
Usage: $0 config_file [workers]
For example: $0 configs/scarlets_and_blues.yaml 8
Tweak [workers] for your system or leave unset.

You may need to do this first:
sudo chown -R "$USER" crawls"

EOF
config="`basename $1 .yaml`"
dir="crawls/collections/$config"
log="${dir}/${config}.log"
err="${dir}/${config}.err"
mkdir -p "$dir"
cat > "$log" <<EOF
Command: $@"
Git remote:
`git remote -v`

Git revision: `git rev-parse HEAD`
Git status:
`git stat`

Docker: `docker --version`
LSB:
`cat /etc/lsb-release`
EOF
cat "$1" | docker run -e CHROME_FLAGS='--incognito' -i -v $PWD/crawls:/crawls/ webrecorder/browsertrix-crawler:0.5.1 crawl --config stdin ${2:+--workers $2} 2>"$err"
exit 0


echo "Command: $@" > "$log"
echo "Git remote:" >> "$log"
git remote -v >> "$log"
echo >> "$log"
echo "Git revision: `git rev-parse HEAD`" >> "$log"
echo "Git status:" >> "$log"
git stat >> "$log"
echo >> "$log"
echo "Docker: `docker --version`" >> "$log"
echo "LSB:" >> "$log"
cat /etc/lsb-release >> "$log"
cat "$1" | docker run -i -v $PWD/crawls:/crawls/ webrecorder/browsertrix-crawler:0.5.1 crawl --config stdin 2>"$err"


This repository contains a few scripts used to drive [Browsertrix Crawler](https://github.com/webrecorder/browsertrix-crawler)
in experiments to archive the [_Scarlets and Blues_](https://www.zooniverse.org/projects/bogden/scarlets-and-blues)
[Zooniverse](https://www.zooniverse.org) project (part of [Engaging Crowds](https://tanc-ahrc.github.io/EngagingCrowds/)).

This will likely work for other Project-Builder-based Zooniverse projects to the same extent that it does for _Scarlets and Blues_.

It is in a "work in progress" state, captured here in the hope that it might be useful. At time of writing, the capture looked pretty good but was missing some subjects. Most images in the documentation (Field Guide, Tutorial, Help) are not captured. I suspect that the former problem was down to the options I was using and it may even be that the options as committed work just fine. The latter problem I suppose might require a custom helper.

Following is just enough information to get started. Windows-friendly edits are welcome. Browsertrix is pretty simple to use so hopefully the scripts are fairly self-explanatory.

A good next step could be to write a tool to check that the archive contains a page for every subject in the project. Comparing pages.jsonl with
the 'subjects' export from the project should do the trick.

## Install Docker

Unless you already have it, of course.

These steps come from https://docs.docker.com/engine/install/ubuntu/
and other sources around the web. I expect that they can be adapted
for Windows. While my instinct is to use my distribution's own packages, for
Docker I found that their recommended approach of adding their own
repository as a package source did work much better.

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt upgrade

sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker "$USER"

su - "$USER" #just to refresh the groups

docker run hello-world
```

## Install browsertrix

Re https://github.com/webrecorder/browsertrix-crawler

`docker pull webrecorder/browsertrix-crawler:latest #I used 0.5.1`


## Install pip dependencies for these helper scripts (optional)

`pip install -r requirements.txt`

Or, better, do this in a virtualenv. I use
[virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/).

```
mkvirtualenv ec_archive
pip install -r requirements.txt
```

## Run a crawl

`./runcrawl.sh configs/scarlets_and_blues.yaml 8`

This might take an hour or two.

`8` is the number of workers to use. It happens to be a good number for me, your mileage may vary.

## Check the crawl

Requires the pip dependencies.

`./badpages.py crawls/collections/scarlets_and_blues/ -l crawls/collections/scarlets_and_blues/scarlets_and_blues.err`


## See roughly what was archived

Requires the pip dependencies.

`./dumpwarc.py crawls/collections/scarlets_and_blues/scarlets_and_blues_0.warc.gz`

`./dumpurls.py crawls/collections/scarlets_and_blues/pages/pages.jsonl`

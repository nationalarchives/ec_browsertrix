#!/bin/bash
#Example: ./makeprofile.sh http://talk.operationwardiary.org
docker run -e CHROME_FLAGS='--incognito' -p 9222:9222 -p 9223:9223 -i -v $PWD/crawls/profiles:/crawls/profiles webrecorder/browsertrix-crawler:0.5.1 create-login-profile --interactive --url "$1"

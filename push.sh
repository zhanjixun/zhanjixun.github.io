#!/bin/bash

set -e

set -v

sed -i 's#http://zhanjixun\.gitee\.io#/#g' "assets/Java知识体系.svg"

rm -rf .idea

git pull

git add -A

git commit -m 'script push'

git push
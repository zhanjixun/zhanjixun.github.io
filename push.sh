#!/bin/bash

set -ev

# rm -rf .idea

find ./assets/drawio -type f -name "*.bkp" -delete

git pull

git add -A

git commit -m 'script push'

git push

# read -n 1 -s -r -p "按任意键退出..."
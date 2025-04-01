#!/bin/bash

set -e

set -v

#sed -i 's#http://zhanjixun\.gitee\.io#/\##g' "assets/Java知识体系.svg"

rm -rf .idea

# 查找未引用的md文件
# tmpfile=$(mktemp)
# grep -o 'markdown/[^)]*' _sidebar.md | 
#   sed 's|markdown/||' | sort > "$tmpfile"
# find markdown -type f -name '*.md' -exec basename {} .md \; | 
#   sort | comm -23 - "$tmpfile" | 
#   sed 's|^|markdown/|;s/$/.md/'

# rm "$tmpfile"

git pull

git add -A

git commit -m 'script push'

git push

# 保持窗口不关闭
read -n 1 -s -r -p "Press any key to exit..."
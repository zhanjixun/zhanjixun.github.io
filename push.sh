set -e

set -v

rm -rf .idea

rm -rf node_modules

rm -rf ./docs/.vuepress/dist

git pull

git add -A

git commit -m '脚本提交'

git push
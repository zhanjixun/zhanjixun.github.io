set -e

set -v

rm -rf .idea
rm -rf node_modules
rm -rf docs/.vuepress/dist

git pull

git add -A
git commit -m '脚本提交'

git push

#########################

npm run docs:build

cd docs/.vuepress/dist
git init
git add -A
git commit -m 'build'
git remote add origin https://gitee.com/zhanjixun/zhanjixun.git
git push -f origin master

rm -rf docs/.vuepress/dist
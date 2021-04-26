set -e

set -v

rm -rf .idea
rm -rf node_modules
rm -rf docs/.vuepress/dist

git pull

git add -A

git commit -m 'script push'

git push

######################### 分开部署到 zhanjixun.gitee.io

#npm run docs:build
#
#cd docs/.vuepress/dist
#git init
#git add -A
#git commit -m build
#git remote add origin https://gitee.com/zhanjixun/zhanjixun.git
#git push -f origin master
#
#cd ../../..
#rm -rf node_modules
#rm -rf docs/.vuepress/dist
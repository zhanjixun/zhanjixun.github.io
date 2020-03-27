set -e

set -v

#切回主干
git checkout master
#先提交主干内容
#sh push.sh
#强制复制一条分支出来
git branch -C deploy
#切换到发布分支
git checkout deploy
#构建博客
npm run docs:build
#删除构建缓存
rm -rf node_modules
#提交博客内容
git add docs/.vuepress/dist
#提交博客内容
git commit -m build_blog
#强推到远程
git push -f origin deploy
#切回主干
git checkout master


set -e

set -v

#切回主干
git checkout master

git pull

git add -A

git commit -m '脚本提交'

git push

# 删除远程发布分支
git push origin --delete deploy

# 删除本地发布分支
git branch -d deploy

# 创建发布分支
git checkout -b deploy

# 构建博客
npm run docs:build

rm -rf node_modules

git add -A

git commit -m 'build'

# 推送构建结果
git push -u origin deploy

#切回主干
git checkout master


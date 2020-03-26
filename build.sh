set -e

set -v
#切回主干
git checkout master

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



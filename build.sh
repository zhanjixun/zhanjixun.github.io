#切回主干
git checkout master

remoteDeployBranch=$(git branch -a | grep remotes/origin/deploy)
if [ -n "$remoteDeployBranch" ]; then
    # 删除远程发布分支
    git push origin --delete deploy
fi

echo '结束'

localDeployBranch=$(git branch | grep deploy)
if [ -n "$localDeployBranch" ]; then
    # 删除本地发布分支
    git branch -d deploy
fi

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



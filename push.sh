set -e

set -v

rm -rf .idea

git pull

git add -A

git commit -m 'script push'

git push
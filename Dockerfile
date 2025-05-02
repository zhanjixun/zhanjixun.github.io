FROM node:latest
WORKDIR /docsify
RUN git clone https://github.com/zhanjixun/zhanjixun.github.io.git /docsify
RUN npm install -g docsify-cli@latest --registry http://registry.npm.taobao.org docify-cli@latest
ENTRYPOINT docsify init . && docsify serve .
# docker有用的工具

**docker-gc**

```shell
#查看可清理的镜像，不执行清理
docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -e DRY_RUN=1 spotify/docker-gc
#清理镜像
docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock spotify/docker-gc
```


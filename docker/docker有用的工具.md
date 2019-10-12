# docker有用的工具

**docker-gc**

docker-gc会删除一个多小时前存在的所有容器。此外，它还会删除不属于任何剩余容器的

```shell
#查看可清理的镜像，不执行清理
docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -e DRY_RUN=1 spotify/docker-gc
#清理镜像
docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock spotify/docker-gc
```

**ctop**

ctop可以用来查看容器的cpu、内存等各项指标。[https://github.com/bcicen/ctop](https://github.com/bcicen/ctop)

```shell
docker run --rm -ti --volume /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop:latest
```


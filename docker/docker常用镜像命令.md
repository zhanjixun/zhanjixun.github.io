# Docker常用镜像命令

### Registry

```shell
docker run -d --name registry \
-v /data/volumns/docker-registry:/var/lib/registry \
-p 5000:5000 --restart=always \
registry:2
```

> registry安装目录结构
>
> /var/lib/registry                                           #存放镜像目录
>
> /etc/docker/registry/config.yml                 #配置文件

在使用私服的docker daemon中配置`/etc/docker/daemon.json`，访问[http://192.168.1.201:5000/v2/_catalog](http://192.168.1.201:5000/v2/_catalog)
```shell
{
     "insecure-registries":["192.168.1.201:5000"] #修改私服所在ip地址
} 
```

### gitlab

```shell
docker run -d --name gitlab -p 9000:9000 \
--restart always \
-v /data/volumns/gitlab/etc:/etc/gitlab \
-v /data/volumns/gitlab/log:/var/log/gitlab \
-v /data/volumns/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:12.0.0-ce.0

vim /data/volumns/gitlab/etc/gitlab.rb
将# external_url 'GENERATED_EXTERNAL_URL' 修改为 external_url 'http://***:9000'
修改为自己的ip

docker exec gitlab gitlab-ctl reconfigure
```

> gitlab安装目录结构
>
> /opt/gitlab/             ## 主目录
> /etc/gitlab/              ## 放置配置文件
> /var/opt/gitlab/       ## 各个组件
> /var/log/gitlab/       ## 放置日志文件
>
> 常用命令
>
> gitlab-ctl status          #检查gitlab组件状态
>
> gitlab-ctl restart         #重启gitlab
>
> gitlab-ctl reconfigure #重载gitlab配置


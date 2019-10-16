# Redis的安装

## 1.ubuntu下安装Redis

**安装**

```shell
sudo apt-get install -y redis-server
```

**检查redis进程、查看端口**

```shell
ps -aux|grep redis
netstat -nlt|grep 6379
```

**重启、停止、状态**

```shell
service redis restart
service redis start
service redis stop
service redis status
```

**查看redis版本**

```shell
redis-server -v #查看服务端版本
redis-cli -v    #查看客户端版本
```

**监听外部连接**

默认安装了redis是只监听本机的连接，也就是只有本机能连接到redis服务器，如果外部需要访问，则需要修改配置文件`/etc/redis/redis.conf`

```shell
sudo vim /etc/redis/redis.conf  #需要使用root权限
```

找到`bind 127.0.0.1 ::1`并将其修改为  `bind 0.0.0.0`

**修改redis服务器密码**

默认安装redis是没有密码的，如果需要修改密码，同样需要修改上面那个配置文件

找到`# requirepass foobared`，取消注释并修改fobared为自己的密码，如 `requirepass 123456`

## 2.window下安装Redis

在github下载redis的压缩包，然后直接解压缩放到你喜欢的位置，如`D:\Redis-x64-3.2.100` 

> [https://github.com/microsoftarchive/redis/releases](https://github.com/microsoftarchive/redis/releases)

进入redis解压目录，双击`redis-server.exe`即可启动redis。这样的方式启动在关闭了窗口服务就关闭了，需要将redis注册成服务，运行以下命令，然后在 `服务` 中就可以找到名为Redis的服务，已经设置为自动启动。

```shell
redis-server.exe --service-install redis.windows.conf --loglevel verbose
```

## 3.Docker中使用Redis

在docker hub搜索redis [https://hub.docker.com/_/redis](https://hub.docker.com/_/redis)，查看相关介绍。

运行redis容器

```shell
 docker run -d --name redis -p 6379:6379 redis:3.2 
```

如果需要开启AOF持久化

```shell
docker run -d --name redis -p 6379:6379 redis:3.2 redis-server --appendonly yes
```

## 4.可视化管理工具RedisDesktopManager

新版的RedisDesktopManager已经不再能免费使用，在github上能找到的最后一个免费安装包是`0.9.3`版本。见[https://github.com/uglide/RedisDesktopManager/releases?after=0.9.4](https://github.com/uglide/RedisDesktopManager/releases?after=0.9.4)，下载地址为：

> [https://github.com/uglide/RedisDesktopManager/releases/download/0.9.3/redis-desktop-manager-0.9.3.817.exe](https://github.com/uglide/RedisDesktopManager/releases/download/0.9.3/redis-desktop-manager-0.9.3.817.exe)

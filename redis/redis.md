# Redis

## 一、简介

redis与memcached的对比

## 二、Redis的安装

### 2.1 ubuntu下安装Redis

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

### 2.2 window下安装Redis

在github下载redis的压缩包，然后直接解压缩放到你喜欢的位置，如`D:\Redis-x64-3.2.100` 

> [https://github.com/microsoftarchive/redis/releases](https://github.com/microsoftarchive/redis/releases)

进入redis解压目录，双击`redis-server.exe`即可启动redis。这样的方式启动在关闭了窗口服务就关闭了，需要将redis注册成服务，运行以下命令，然后在 `服务` 中就可以找到名为Redis的服务，已经设置为自动启动。

```shell
redis-server.exe --service-install redis.windows.conf --loglevel verbose
```

### 2.3 Docker中使用Redis

在docker hub搜索redis [https://hub.docker.com/_/redis](https://hub.docker.com/_/redis)，查看相关介绍。

运行redis容器

```shell
 docker run -d --name redis -p 6379:6379 redis:3.2 
```

如果需要开启AOF持久化

```shell
docker run -d --name redis -p 6379:6379 redis:3.2 redis-server --appendonly yes
```

### 2.4 可视化管理工具RedisDesktopManager

新版的RedisDesktopManager已经不再能免费使用，在github上能找到的最后一个免费安装包是`0.9.3`版本。见[https://github.com/uglide/RedisDesktopManager/releases?after=0.9.4](https://github.com/uglide/RedisDesktopManager/releases?after=0.9.4)，下载地址为：

> [https://github.com/uglide/RedisDesktopManager/releases/download/0.9.3/redis-desktop-manager-0.9.3.817.exe](https://github.com/uglide/RedisDesktopManager/releases/download/0.9.3/redis-desktop-manager-0.9.3.817.exe)

## 三、Redis的数据类型与基本命令

### 3.1 五种数据类型

Redis中常用的数据类型有5中，它们分别是字符串（String）、列表（List）、集合（set）、哈希结构（hash）和有序集合（zset）。以下表格列出了它们的基本描述。

| 数据类型 | 可以存储的值                                                 | 描述                                            |
| -------- | ------------------------------------------------------------ | ----------------------------------------------- |
| 字符串   | 字符串、整数或浮点数                                         | 1.对字符串操作 2.对整数或浮点型可以计算，如自增 |
| 列表     | 本质是一个链表，每个节点包含一个字符串                       |                                                 |
| 集合     | 无序唯一集合，节点是字符串                                   |                                                 |
| 哈希结构 | 包含键值对的无序散列表                                       |                                                 |
| 有序集合 | 有序集合，节点可以是字符串、整数或浮点数和分值，元素排序依据分值大小 |                                                 |



### 3.2 基本命令操作

**测试连接**

```shell
127.0.0.1:6379> ping
PONG
```

**登录到redis服务器**

```shell
#登录到本机
redis-cli
```

```shell
#登录到远程redis服务器
redis-cli -h 192.168.0.100 -p 6379 -a 123456
```

> -h 服务器地址 如localhost
>
> -p 服务器端口 默认6379
>
> -a 登录密码
>
> -n 选择某个数据库 默认为0

**切换数据库**

```shell
localhost:6379> select 1
OK
```

> select index  #其中index为数据库下标索引 可用值为0~15



## 四、五种数据类型及使用场景

## 五、持久化原理及数据失效场景

## 六、Redis事务管理机制

## 七、主从复制

## 八、哨兵机制

## 九、内存管理

## 十、Redis集群

## 十一、常见问题处理

## 十二、Redis服务器的监控


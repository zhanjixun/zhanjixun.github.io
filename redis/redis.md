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

| 数据类型 | 可以存储的值                             | 描述                         |
| ---- | ---------------------------------- | -------------------------- |
| 字符串  | 字符串、整数或浮点数                         | 1.对字符串操作 2.对整数或浮点型可以计算，如自增 |
| 列表   | 本质是一个双向链表，每个节点包含一个字符串，有序           |                            |
| 集合   | 无序唯一集合，节点是字符串                      |                            |
| 哈希结构 | 包含键值对的无序散列表                        |                            |
| 有序集合 | 有序集合，节点可以是字符串、整数或浮点数和分值，元素排序依据分值大小 |                            |

### 3.2 基本命令操作

以下列出常用的操作命令，具体可参考[http://doc.redisfans.com/](http://doc.redisfans.com/)。

#### 3.2.1 基本操作

##### 登录到redis服务器

```shell
#登录到本机
redis-cli

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

##### 切换数据库

```shell
localhost:6379> select 1
OK
```

> select index  #其中index为数据库下标索引 可用值为0~15

##### 测试连接

```shell
127.0.0.1:6379> ping
PONG
```

#### 3.2.2 字符串类型操作

##### 设置字符串键值对

```shell
SET key value [EX seconds] [PX milliseconds] [NX|XX]
```

> 设置键key的值为value，如果key已经存在，会直接覆盖旧值。
>
> EX second              #可选参数,设置键的过期时间，单位秒
>
> PX millisecond       #设置键的过期时间，单位毫秒
>
> NX                           #当key不存在时候，才进行设置操作
>
> XX                           #当key存在时候，才进行设置操作

```shell
127.0.0.1:6379> set name zhanjixun
OK
127.0.0.1:6379> get name
"zhanjixun"
127.0.0.1:6379> set age 23 ex 5
OK
127.0.0.1:6379> get age
"23"
127.0.0.1:6379> get age
(nil)
127.0.0.1:6379> set name zhanjixun nx
(nil)
127.0.0.1:6379> set age 23 nx
OK
127.0.0.1:6379> set name zhanjixun xx
OK
```

##### 获取字符串值

```shell
GET key
```

> 获取一个字符串类型的储存的值。如果key不存在则返回特殊值nil。如果key储存的值不是字符串（如是列表），则返回一个错误。

```shell
127.0.0.1:6379> GET name
(nil)
127.0.0.1:6379> SET name zhanjixun
OK
127.0.0.1:6379> GET name
"zhanjixun"
127.0.0.1:6379> DEL name
(integer) 1
127.0.0.1:6379> LPUSH name zhanjixun jixun zjx
(integer) 3
127.0.0.1:6379> GET name
(error) ERR Operation against a key holding the wrong kind of value
```

##### 删除键值对

```shell
DEL key [key ...]
```

> 删除键值对，适用于所有数据类型。不存在的key会被忽略

##### 计算字符串长度

```shell
STRLEN key
```

> 计算字符串的长度，当 key 不存在时，返回0 ，当 key 储存的不是字符串值时，返回一个错误。

```shell
127.0.0.1:6379> SET name zhanjixun
OK
127.0.0.1:6379> strlen name
(integer) 9
127.0.0.1:6379> strlen none
(integer) 0
```

##### 修改并返回旧值

```shell
GETSET key value
```

> 将给定 key 的值设为 value ，并返回 key 的旧值(old value)。
>
> 当 key 存在但不是字符串类型时，返回一个错误。

```shell
127.0.0.1:6379> set name zhanjixun
OK
127.0.0.1:6379> getset name  jixun
"zhanjixun"
127.0.0.1:6379> get name
"jixun"
```

##### 获取子字符串

```shell
GETRANGE key start end
```

> 获取字符串的子串，截取范围为:[start,end] 
>
> 偏移量从0开始计数，0代表字符串第一位
>
> 负偏移量表示从字符串最后开始计数

```shell
127.0.0.1:6379> set name zhanjixun
OK
127.0.0.1:6379> getrange name 4 9
"jixun"
```

##### 追加字符串

```shell
APPEND key value
```

> 如果key存在并且是字符串类型，则追加value到key原来的值后面
>
> 如果key不存在，则设置key的值为value，相当于 set key value
>
> 返回追加之后字符串的长度

#### 3.2.3 列表类型操作

Redis中的列表本质是一种双向链表结构，因此可以从左到右，可以从右到左遍历它的节点。使用双向链表在插入和删除时候会更加便利，但是会牺牲以下读的性能。如果要安装节点下标来查询，需要从头遍历，在大量数据的情况下，性能并不是很好。因为是双向链表，列表的操作分为从左到右和从右到左，相关的命令为lxx和rxx。

##### 给列表加入节点

```shell
LPUSH key value [value ...]
RPUSH key value [value ...]
```

> 将一个或多个值从左（右）插入到列表中，返回插入操作后列表的长度

##### 删除节点并返回

```shell
LPOP key
RPOP key
```

> 删除第一个（最后一个）节点，并返回，当节点不存在时返回nil

##### 按节点下标查找

```shell
LINDEX key index
```

> 从左向右按节点下标查找节点返回，可以使用负数下标，下标从0开始
>
> 请注意，并没有RINDEX ，如果要从右到左查找，使用负数，如-10代表从右到左第10个节点

##### 查看列表长度

```shell
LLEN key
```

> 返回列表长度，如果key不存在，返回0。如果key数据类型不是列表，返回异常。

#### 3.2.4 哈希结构类型操作



#### 3.2.5 集合类型操作



#### 3.2.6 无序集合类型操作



## 四、五种数据类型及使用场景

### 4.1 字符串类型[String]

### 4.2 列表类型[List]

### 4.3 哈希类型[Hash]

### 4.4 集合类型[set]

### 4.5 有序集合类型[zset]

## 五、持久化原理及数据失效场景

## 六、Redis事务管理机制

## 七、主从复制

## 八、哨兵机制

## 九、内存管理

## 十、Redis集群

## 十一、常见问题处理

## 十二、Redis服务器的监控


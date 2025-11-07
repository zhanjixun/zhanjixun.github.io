# Redis的五种数据类型及使用场景

Redis有五种数据类型，分别是：`string`、`hash`、`list`、`set`和`zset`

| 类型           | 结构                                              | 使用场景                                                     |
| -------------- | ------------------------------------------------- | ------------------------------------------------------------ |
| 字符串(string) | 可存储文本、数字或二进制数据                      | 字符串缓存，计数器（自增自减），分布式锁，二进制文件（序列化对象或图片） |
| 哈希(hash)     | 键值对的集合，适合存储对象（如用户信息）          | 对象缓存，部分更新，聚合数据                                 |
| 列表(list)     | 双向链表，支持在头部或尾部快速插入/删除元素       | 消息队列                                                     |
| 集合(set)      | 无序且元素唯一的集合，支持交/并/差集运算          | 标签系统，好友关系，抽奖去重                                 |
| 有序集合(zset) | 元素唯一且按关联的分数（Score）排序，支持范围查询 | 排行榜，优先级队列，延迟队列                                 |

## 操作命令

### 字符串(string)

`SET key value`：设置值

`GET key`：获取值

`INCR key` / `DECR key`：自增/自减整数

### 哈希(hash)

`HSET key field value`：设置字段值

`HGET key field`：获取字段值

### 列表(list)

`LPUSH key value1 value2...` / `RPUSH key value1 value2...`：从左/右插入元素

`LPOP key` / `RPOP key`：从左/右弹出元素

### 集合(set)

`SADD key member1 member2...`：添加元素

`SREM key member1 member2...`：删除元素

`SMEMBERS key`：获取所有元素

`SISMEMBER key member`：检查元素是否存在

`SINTER key1 key2...` / `SUNION` / `SDIFF`：交集/并集/差集

### 有序集合(zset)

`ZADD key score1 member1 score2 member2...`：添加元素

`ZRANGE key start end [WITHSCORES]`：按分数升序获取元素

`ZREVRANGE key start end [WITHSCORES]`：按分数降序获取元素

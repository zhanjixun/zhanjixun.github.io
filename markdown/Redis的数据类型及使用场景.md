# Redis的数据类型及使用场景

## 常用核心数据类型

Redis常用的核心数据类型有5种，分别是：`string`、`hash`、`list`、`set`和`zset`

| 字段   | 类型     | 结构                                              | 使用场景                                                     |
| ------ | -------- | ------------------------------------------------- | ------------------------------------------------------------ |
| String | 字符串   | 可存储文本、数字或二进制数据                      | 字符串缓存，计数器（自增自减），分布式锁，二进制文件（序列化对象或图片） |
| Hash   | 哈希     | 键值对的集合，适合存储对象                        | 对象缓存，部分更新，聚合数据                                 |
| List   | 列表     | 双向链表，支持在头部或尾部快速插入/删除元素       | 消息队列                                                     |
| Set    | 集合     | 无序且元素唯一的集合，支持交/并/差集运算          | 标签系统，好友关系，抽奖去重                                 |
| ZSet   | 有序集合 | 元素唯一且按关联的分数（Score）排序，支持范围查询 | 排行榜，优先级队列，延迟队列                                 |

### 基础操作命令

```shell
# 字符串
# 设置值
SET key value
# 获取值
GET key
# 自增/自减整数
INCR key
DECR key

# 列表
# 从左/右插入元素 单个或多个
LPUSH key value1 value2 (...) 
RPUSH key value1 value2 (...)
# 从左/右弹出元素
LPOP key
RPOP key

# 哈希
# 设置字段值
HSET key field value
# 获取字段值
HGET key field
# 获取所有字段
HGETALL key

# 集合
# 添加元素
SADD key member1 member2 (...) 
# 删除元素
SREM key member1 member2 (...) 
# 获取所有元素
SMEMBERS key 
# 检查元素是否存在
SISMEMBER key member
# 交集/并集/差集
SINTER key1 key2 (...) 
SUNION key1 key2 (...) 
SDIFF key1 key2 (...) 

# 有序集合
# 添加元素
ZADD key score1 member1 score2 member2 (...) 
# 按分数升序获取元素
ZRANGE key start end [WITHSCORES]
# 按分数降序获取元素
ZREVRANGE key start end [WITHSCORES]
```

## 高级数据类型
| 字段        | 类型     | 结构                                         | 使用场景                           |
| ----------- | -------- | -------------------------------------------- | ---------------------------------- |
| Bitmap      | 位图     | 使用字符串存储二进制位信息                   | 用户签到、活跃用户统计、UV统计     |
| HyperLogLog | 基数统计 | 用于估算集合中不同元素的数量（不精确但高效） | 统计网站 UV、独立访客数            |
| Geo         | 地理位置 | 存储经纬度，可计算距离、范围查找             | 附近的人、附近的店铺               |
| Stream      | 流       | Redis 5.0 引入的消息队列结构，支持消费组     | 日志流、消息队列（Kafka 替代方案） |

此外，Redis还支持Module 扩展数据结构，通过模块实现。这些需要加载 Redis 模块：

- **Bloom Filter（布隆过滤器）**：用于快速判断元素是否存在。
- **Cuckoo Filter**：布隆过滤器的改进版。
- **Count-Min Sketch**：统计频率。
- **Top-K**：获取出现次数最多的前 K 个元素。
- **RedisJSON**：支持 JSON 对象存储和查询。
- **RedisSearch**：全文搜索、排序、索引。

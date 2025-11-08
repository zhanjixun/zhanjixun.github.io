# Redis除了做缓存还能做什么

## 缓存以外的常见用途

### 分布式锁

利用 `SETNX`（或 `SET key value NX EX`） 可以轻松实现**分布式锁**。

### 布隆过滤器/去重系统

借助 BitMap 或 RedisBloom 模块可实现高效去重、存在性判断。

```
BF.ADD user_exist user123
BF.EXISTS user_exist user123
```

**场景**：防止重复注册、防止重复爬取 URL。

### 消息队列

Redis 的 `List`、`Stream` 结构都可以天然用于消息队列。

**List 实现简单队列**
 用 `LPUSH` + `RPOP` 模拟消息入队出队

```
LPUSH queue task1
RPOP queue  → task1
```

**Stream 实现高级队列（推荐）**
 支持消费组、消息确认、持久化等功能（类似 Kafka）

```
XADD mq * user jim action login
XGROUP CREATE mq group1 $
XREADGROUP GROUP group1 consumer1 STREAMS mq >
```

### 限流

可以基于计数或滑动窗口算法，用 Redis 实现请求限流。

**计数器限流**

  ```
  INCR api:count:uid123
  EXPIRE api:count:uid123 60
  ```

  → 统计一分钟内请求次数，超过则限流。

**场景**：防止接口被刷、秒杀活动保护。

### 排行榜与积分系统

利用 **ZSet（有序集合）** 存储用户积分、分数。

```
ZADD rank 200 userA
ZADD rank 150 userB
ZREVRANGE rank 0 9 WITHSCORES
```

**场景**：游戏排行榜、直播打赏榜、用户活跃榜。

### 会话（Session）与Token存储

Redis 的高性能和过期机制很适合存储用户会话。

**Session缓存**

  ```
  SETEX session:uid123 token_xyz 1800
  ```

 **场景**：Web 登录状态保持、分布式 Session 管理。

### 计数器系统

利用原子操作 `INCR`、`DECR` 可快速实现各种计数逻辑。

```
INCR view:article:1001
```

 **场景**：浏览量统计、点赞数、访问计数器。

### 地理位置服务（Geo）

存储地理坐标并进行范围查找或距离计算。

```
GEOADD shop 116.40 39.90 "Beijing"
GEORADIUS shop 116.41 39.91 5 km
```

 **场景**：附近的人、附近的商家。

### 延迟队列

利用 **ZSet** 存储任务执行时间，通过 score 排序实现延迟执行。

```
ZADD delay_task 1730974820 task:send_email
ZRANGEBYSCORE delay_task 0 current_timestamp
```

 **场景**：延时消息、订单超时取消。

### 大数据分析

- **HyperLogLog**：快速估算独立访客数（UV）
- **Bitmap**：高效签到、活跃用户记录

 **场景**：日活统计、签到、唯一访问统计。

### 分布式协调 / 注册中心

利用 Redis 的发布订阅（Pub/Sub）或 Key 监听机制，
 可以实现简单的**服务发现、配置变更通知**。

```
SUBSCRIBE config_update
PUBLISH config_update "reload"
```

 **场景**：微服务间配置同步、通知广播。
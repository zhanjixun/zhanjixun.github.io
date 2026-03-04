# Redis实现分布式锁

## 基本实现思路

**使用Redis命令**：

```shell
SETNX key value
EXPIRE key
# SETNX不能同时设置过期时间，不能保证命令的原子性

SET key value [EX seconds] [PX milliseconds] [NX|XX]
# EX seconds：设置失效时长，单位秒
# PX milliseconds：设置失效时长，单位毫秒
# NX：key不存在时设置value，成功返回OK，失败返回(nil)
# XX：key存在时设置value，成功返回OK，失败返回(nil)
```

**解锁逻辑**：

释放锁时必须校验是否是自己加的锁，避免误删：

1. 先判断 key 对应的 value 是否是自己设置的；
2. 如果是，执行 `DEL key` 删除；
3. 否则不操作。

为保证**原子性**，需要使用**Lua脚本**完成检查 + 删除。

**Java实现代码**：

```java
// 尝试加锁
public String tryLock() {
    String lockValue = UUID.randomUUID().toString();
    String result = jedis.set(lockKey, lockValue, "NX", "EX", expireTime);
    if ("OK".equals(result)) {
        return lockValue; // 加锁成功
    }
    return null; // 加锁失败
}

// 释放锁（通过Lua脚本保证原子性）
public boolean unlock(String lockValue) {
    String luaScript =
            "if redis.call('get', KEYS[1]) == ARGV[1] then " +
            "   return redis.call('del', KEYS[1]) " +
            "else " +
            "   return 0 " +
            "end";
    Object result = jedis.eval(luaScript, 1, lockKey, lockValue);
    return "1".equals(result.toString());
}
```

## 问题与解决方案

如上方案设计的分布式锁存在多种隐患问题：

1. **锁自动过期**导致误释放

   > 解决思路：加锁成功启动周期线程判断锁的值跟加锁的值一致则续约过期时间；释放锁时候停止需求线程

2. **不可重入性**

   > 解决思路：1、用 `ThreadLocal` 记录重入次数；2、Hash结构存储「锁持有者标识 + 重入计数」

3. **误删其他客户端的锁**

   > 解决思路：value存唯一标识，校验一致再释放；需要注意的是java中先get再del不能保证原子性，需要使用Lua脚本

4. **单节点故障**/**主从复制失败导致锁丢失**

   > 解决思路：1、RedLock算法；2、使用 Redis Sentinel 或 Cluster（主从 + 自动切换）；3、Redis + DB/MQ 补偿（业务强一致性）

### 自动续约

```java
// 续约线程池
private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
// 用于保存每个线程的锁标识
private final ThreadLocal<String> lockValueHolder = new ThreadLocal<>();

private volatile ScheduledFuture<?> renewTask;

// 尝试加锁
public boolean tryLock() {
    String lockValue = UUID.randomUUID().toString();
    String result = jedis.set(lockKey, lockValue, "NX", "EX", expireTime);

    if ("OK".equals(result)) {
        lockValueHolder.set(lockValue);
        // 启动自动续期线程
        startAutoRenew();
        return true;
    }
    return false;
}

// 自动续约逻辑
private void startAutoRenew() {
    // 每 (expireTime / 3) 秒续约一次（Redisson 默认 1/3）
    long period = expireTime * 1000L / 3;
    renewTask = scheduler.scheduleAtFixedRate(() -> {
        try {
            String lockValue = lockValueHolder.get();
            if (lockValue == null) return;

            String currentValue = jedis.get(lockKey);
            if (lockValue.equals(currentValue)) {
                // 续约锁的过期时间
                jedis.expire(lockKey, expireTime);
                System.out.println("🔄 自动续约成功，延长锁时间：" + lockKey);
            } else {
                // 不是自己的锁，停止续约
                stopAutoRenew();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }, period, period, TimeUnit.MILLISECONDS);
}

private void stopAutoRenew() {
    if (renewTask != null && !renewTask.isCancelled()) {
        renewTask.cancel(true);
    }
}

// 释放锁（Lua脚本原子操作）
public boolean unlock() {
    try {
        String lockValue = lockValueHolder.get();
        if (lockValue == null) return false;

        String luaScript =
                "if redis.call('get', KEYS[1]) == ARGV[1] then " +
                "   return redis.call('del', KEYS[1]) " +
                "else " +
                "   return 0 " +
                "end";
        Object result = jedis.eval(luaScript, 1, lockKey, lockValue);
        boolean success = "1".equals(result.toString());
        if (success) {
            stopAutoRenew();
            lockValueHolder.remove();
        }
        return success;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}
```

### 可重入

1、使用 `ThreadLocal` 记录重入次数：

本地记录每个线程重入次数，

加锁时重入次数大于0则只增加次数，否则执行加锁；

释放锁时重入次数大于1则只减少次数，计数为1时释放锁。

```java
private ThreadLocal<Integer> reentryCount = ThreadLocal.withInitial(() -> 0);
private ThreadLocal<String> lockValue = new ThreadLocal<>();

// 加锁
public boolean tryLock() {
    if (reentryCount.get() > 0) {
        reentryCount.set(reentryCount.get() + 1);
        return true; // 本地重入
    }

    String value = UUID.randomUUID().toString();
    if ("OK".equals(jedis.set(lockKey, value, "NX", "EX", expireTime))) {
        lockValue.set(value);
        reentryCount.set(1);
        return true;
    }
    return false;
}
// 释放锁
public void unlock() {
    if (reentryCount.get() > 1) {
        reentryCount.set(reentryCount.get() - 1);
        return; // 仅减少计数
    }
    // 计数为1，释放锁
    String lua = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";
    jedis.eval(lua, 1, lockKey, lockValue.get());
    reentryCount.remove();
    lockValue.remove();
}
```

2、Redis中用Hash存储重入次数

这是最通用、可靠的方案（Redisson 就是这样实现的）。

```java
// Redis中锁结构：Hash类型 { owner=线程ID, count=1 }

public boolean tryLock() {
    String threadId = getThreadId();
    String result = jedis.set(lockKey, threadId, "NX", "EX", expireTime);
    if ("OK".equals(result)) return true; // 首次加锁成功

    String currentOwner = jedis.get(lockKey);
    if (threadId.equals(currentOwner)) {
        // 当前线程已持有锁，重入
        jedis.hincrBy(lockKey + ":count", "count", 1);
        jedis.expire(lockKey, expireTime);
        return true;
    }
    return false;
}

public void unlock() {
    String threadId = getThreadId();
    String currentOwner = jedis.get(lockKey);
    if (threadId.equals(currentOwner)) {
        long count = jedis.hincrBy(lockKey + ":count", "count", -1);
        if (count <= 0) jedis.del(lockKey);
    }
}
```

### RedLock算法

RedLock 是 Redis 作者提出的一种**多节点分布式锁算法**，用于避免单点故障。

原理：

1. 使用 **N（≥5）个独立 Redis 实例**；
2. 客户端在每个实例上尝试加锁，设置相同的过期时间；
3. 如果 **超过半数节点加锁成功**，则认为锁获取成功；
4. 解锁时在所有节点删除锁。

```java
// 尝试加锁
public String tryLock() {
    String lockValue = UUID.randomUUID().toString();
    long startTime = System.currentTimeMillis();
    int successCount = 0;

    for (Jedis jedis : redisNodes) {
        try {
            String result = jedis.set(lockKey, lockValue, "NX", "PX", expireTime);
            if ("OK".equals(result)) {
                successCount++;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    long elapsed = System.currentTimeMillis() - startTime;

    // 加锁成功条件：超过半数节点成功 + 总耗时 < 锁过期时间
    if (successCount >= (redisNodes.size() / 2 + 1) && elapsed < expireTime) {
        return lockValue;
    } else {
        // 未成功，加锁失败时释放已加锁节点
        unlock(lockValue);
        return null;
    }
}

// 解锁
public void unlock(String lockValue) {
    String luaScript =
        "if redis.call('get', KEYS[1]) == ARGV[1] then " +
        "   return redis.call('del', KEYS[1]) " +
        "else " +
        "   return 0 " +
        "end";
    for (Jedis jedis : redisNodes) {
        try {
            jedis.eval(luaScript, 1, lockKey, lockValue);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## 使用Redisson

Redisson 是一个成熟的 Redis 客户端，封装了可靠的分布式锁逻辑（自动续期、可重入锁等）。

```java
Config config = new Config();
config.useSingleServer().setAddress("redis://127.0.0.1:6379");
RedissonClient redisson = Redisson.create(config);

RLock lock = redisson.getLock("myLock");

try {
    // 尝试获取锁，最多等待100ms，锁定10秒
    if (lock.tryLock(100, 10, java.util.concurrent.TimeUnit.SECONDS)) {
        System.out.println("获取锁成功，执行业务逻辑...");
        Thread.sleep(5000);
    }
} catch (InterruptedException e) {
    e.printStackTrace();
} finally {
    if (lock.isHeldByCurrentThread()) {
        lock.unlock();
        System.out.println("释放锁");
    }
    redisson.shutdown();
}
```

Redisson 的核心优势：

1. **可重入性**：使用Redis中Hash结构记录重入次数，根据计数器释放锁，类似 `ReentrantLock`
2. **自动续约（Watchdog）**：定期检查锁是否被业务线程持有，如果持有，则自动延长锁的过期时间
3. **RedLock 高可用**：支持 **RedLock** 算法，适合多节点部署
4. **多种锁类型**：可重入独占锁、读写锁、公平锁、分布式信号量、分布式倒计时锁
5. **异步和阻塞调用**：`tryLockAsync()`、`lockAsync()` 支持异步操作；可以直接指定超时和等待时间
6. **可靠性**：内置 Lua 脚本保证原子性

# Lock体系

Java 中的 `Lock` 接口是 `java.util.concurrent.locks` 包的核心，相比于传统的 `synchronized` 关键字，它提供了更细粒度、更灵活的锁操作。

以下是关于 Java Lock 的核心知识点总结：

------

## Lock 与 synchronized 的区别

虽然两者都用于解决线程安全问题，但 Lock 提供了更高的可控性：

| **特性**     | **synchronized**                | **Lock 接口**                         |
| ------------ | ------------------------------- | ------------------------------------- |
| **实现层面** | JVM 层面（关键字）              | JDK 层面（API 接口）                  |
| **灵活性**   | 自动释放锁，不可中断            | 需手动释放，支持尝试获取锁、可中断    |
| **公平性**   | 只支持非公平锁                  | 支持公平锁与非公平锁                  |
| **条件变量** | 只有一个等待队列（wait/notify） | 支持多个 Condition 条件（更精准唤醒） |
| **性能**     | 锁升级优化后，低竞争下表现极好  | 高竞争、复杂业务场景下更具优势        |

------

## Lock 接口的核心方法

在使用 `Lock` 时，**必须**在 `finally` 块中释放锁，以防止程序异常导致死锁。

- `lock()`: 获取锁，如果锁被占用则阻塞。
- `tryLock()`: 尝试获取锁，立即返回 true 或 false，**不阻塞**。
- `tryLock(long time, TimeUnit unit)`: 在指定时间内尝试获取锁。
- `lockInterruptibly()`: 可中断地获取锁（在等待时可以响应 `Thread.interrupt()`）。
- `unlock()`: 释放锁。

------

## 常见的 Lock 实现类

### ReentrantLock (重入锁)

最常用的实现类。支持“重入”，即一个线程可以多次获得同一把锁。

- **公平性选择**：`new ReentrantLock(true)` 开启公平锁（按等待时间排序）。
- **核心原理**：基于 **AQS** (AbstractQueuedSynchronizer) 实现。

### ReentrantReadWriteLock (读写锁)

维护了一对锁：一个读锁和一个写锁。

- **规则**：读-读共享，读-写互斥，写-写互斥。
- **场景**：适用于**读多写少**的并发场景，极大提高读取性能。

### StampedLock (邮戳锁)

Java 8 引入，是对读写锁的优化。

- 支持**乐观读**，在读的过程中允许写操作介入，通过“邮戳”校验数据是否被修改，性能比读写锁更高。

------

## 核心组件：Condition

`Condition` 接口替代了传统的 `Object.wait/notify`，用于线程间的通信。

- 通过 `lock.newCondition()` 创建。
- `await()` 让当前线程等待。
- `signal()` / `signalAll()` 唤醒等待线程。
- **优势**：可以创建多个 Condition（如 `notFull` 和 `notEmpty`），实现**精准唤醒**特定类别的线程。

------

## 核心原理：AQS (AbstractQueuedSynchronizer)

它是 Lock 实现的基石。

- **State 变量**：使用一个 `volatile int` 类型的变量表示锁的状态（如 0 为空闲，1 为占用）。
- **CAS 操作**：利用 Unsafe 类的 CAS 原子性地修改 state。
- **CLH 队列**：一个双向同步队列，存放那些获取锁失败而进入阻塞状态的线程。

------

## 使用最佳实践

1. **规范模板**：

   ```Java
   Lock lock = new ReentrantLock();
   lock.lock(); // 加锁处在 try 之外
   try {
       // 临界区代码
   } finally {
       lock.unlock(); // 确保释放锁
   }
   ```
   
2. **避免死锁**：尽量使用 `tryLock` 带有超时时间的版本。

3. **选择合适的锁**：如果读操作非常频繁，优先考虑 `ReadWriteLock` 或 `StampedLock`。
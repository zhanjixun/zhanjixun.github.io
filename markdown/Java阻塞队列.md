# Java阻塞队列

Java 中的 **阻塞队列（BlockingQueue）** 是 `java.util.concurrent` 包下最重要的组件之一。它不仅是一个数据容器，更是并发编程中**解耦生产者与消费者**的核心利器。

------

## 1. 什么是阻塞队列？

`BlockingQueue` 是一个接口，继承自 `Queue`。它的独特之处在于提供了两个附加操作：

- **阻塞添加**：当队列满时，尝试添加元素的线程会被阻塞，直到队列有空位。
- **阻塞移除**：当队列空时，尝试获取元素的线程会被阻塞，直到队列有新数据。

------

## 2. 核心方法对比

根据你对“阻塞”的需求程度，`BlockingQueue` 提供了四套不同的 API：

| **行为** | **抛出异常** | **返回特殊值**          | **阻塞等待** | **超时退出**           |
| -------- | ------------ | ----------------------- | ------------ | ---------------------- |
| **插入** | `add(e)`     | `offer(e)` (返回 false) | **`put(e)`** | `offer(e, time, unit)` |
| **移除** | `remove()`   | `poll()` (返回 null)    | **`take()`** | `poll(time, unit)`     |
| **检查** | `element()`  | `peek()`                | 不适用       | 不适用                 |

------

## 3. 常见的阻塞队列实现

### ① ArrayBlockingQueue (有界)

- **底层**：数组。
- **特点**：必须指定容量（有界）。生产者和消费者**共用同一把重入锁**。
- **性能**：因为锁竞争在同一个对象上，在高并发下吞吐量略低于 `LinkedBlockingQueue`。

### ② LinkedBlockingQueue (可选界)

- **底层**：单向链表。
- **特点**：默认容量为 `Integer.MAX_VALUE`（接近无界，容易导致 OOM，建议手动指定）。
- **性能**：使用了**两把锁（takeLock 和 putLock）**，实现了“读写分离”，生产者和消费者可以并行操作，性能更高。

### ③ SynchronousQueue (不存储元素)

- **特点**：容量为 0。每一个 `put` 操作必须等待一个 `take` 操作，否则无法继续添加。
- **应用**：`Executors.newCachedThreadPool()` 就使用了它，适合任务传递，不适合存储任务。

### ④ PriorityBlockingQueue (优先级)

- **特点**：支持优先级的无界队列。元素按照自然顺序或指定的 `Comparator` 排序。
- **注意**：因为是无界的，`put` 操作永远不会阻塞，但 `take` 在空时会阻塞。

### ⑤ DelayQueue (延迟)

- **特点**：只有当元素的延迟时间到了，才能从队列中获取。
- **场景**：缓存系统设计、定时任务调度。

------

## 4. 阻塞的底层原理

正如前面提到的，其核心在于 `AbstractQueuedSynchronizer` (AQS) 的条件等待机制。

Java

```
// 以 ArrayBlockingQueue 的 put(e) 简化源码为例
public void put(E e) throws InterruptedException {
    final ReentrantLock lock = this.lock;
    lock.lockInterruptibly(); // 1. 加锁
    try {
        while (count == items.length)
            notFull.await();  // 2. 队列满，线程进入等待集并释放锁
        enqueue(e);           // 3. 入队
        notEmpty.signal();    // 4. 唤醒因空而阻塞的消费者
    } finally {
        lock.unlock();        // 5. 释放锁
    }
}
```

------

## 5. 为什么在线程池中使用它？

阻塞队列是 Java 线程池（`ThreadPoolExecutor`）的灵魂。

1. **平衡压力**：当任务产生速度大于处理速度时，队列作为缓冲。
2. **线程管理**：当没有任务时，线程池中的工作线程通过 `workQueue.take()` 自动阻塞挂起，不占用 CPU 资源；一旦有任务，线程会被自动唤醒。

------

## 6. 如何选择？

- **追求吞吐量**：首选 `LinkedBlockingQueue`。
- **内存敏感/防止 OOM**：务必使用有界的 `ArrayBlockingQueue` 或指定大小的 `LinkedBlockingQueue`。
- **一对一实时交换**：使用 `SynchronousQueue`。
- **任务有轻重缓急**：使用 `PriorityBlockingQueue`。


# ThreadLocal

## 简介

ThreadLocal通过为每个线程维护一个独立的变量副本来实现**线程隔离**。

> **为什么要用ThreadLocal**
>
> 并发场景下，会存在多个线程同时修改一个共享变量的场景。这就可能会出现**线性安全**问题。
>
> 为了解决线性安全问题，可以用加锁的方式，比如使用`synchronized` 或者`Lock`。但是加锁的方式，可能会导致系统变慢。
>
> 另外一种方案，就是使用空间换时间的方式，即使用`ThreadLocal`。使用`ThreadLocal`类访问共享变量时，会在每个线程的本地，都保存一份共享变量的拷贝副本。多线程对共享变量修改时，实际上操作的是这个变量副本，从而保证线性安全。

## 基本使用

ThreadLocal对象提供3个公有方法 ：set()、get()和remove()。基本的操作就是set设值，get取值。就是一个存取数据的用法。

```java
ThreadLocal<Object> threadLocal1 = new ThreadLocal<>();
ThreadLocal<Object> threadLocal2 = new ThreadLocal<>();
for (int i = 0; i < 2; i++) {
    new Thread(() -> {
        threadLocal1.set(Thread.currentThread().getId() + "-1");
        threadLocal2.set(Thread.currentThread().getId() + "-2");

        System.out.println(threadLocal1.get());
        System.out.println(threadLocal2.get());
        threadLocal1.remove();
        threadLocal2.remove();
    }).start();
}
```

## 数据结构

每个 `Thread` 对象内部持有一个 `ThreadLocalMap`（类似哈希表），用于存储该线程的所有 `ThreadLocal` 变量。

**键值对结构**：

- **键（Key）**：`ThreadLocal` 实例本身（弱引用，避免内存泄漏）。
- **值（Value）**：线程对应的变量副本。

```java
public class Thread implements Runnable { 
    //当前线程的ThreadLocalMap
    ThreadLocal.ThreadLocalMap threadLocals = null;
}

static class ThreadLocalMap {
    //实际存放数据的对象，包含key和value
    private Entry[] table;
}
```

变量访问逻辑：

**`get()` 方法流程**：

1. 获取当前线程的 `ThreadLocalMap`。
2. 以当前 `ThreadLocal` 实例为键，查找对应的值。
3. 若未找到，调用 `initialValue()` 初始化并存储默认值。

**`set(T value)` 方法流程**：

1. 获取当前线程的 `ThreadLocalMap`。
2. 以当前 `ThreadLocal` 实例为键，插入或更新值。

## 哈希冲突

**开放地址法**：`ThreadLocalMap` 使用线性探测法（而非拉链法）解决哈希冲突。

**魔数哈希**：通过 `0x61c88647`（斐波那契散列）计算索引，均匀分布键值对，减少冲突概率。

## 对过期key的清理

ThreadLocal对过期key的清理方式分为两种清理方式，分别是探测式清理和启发式清理。

### 探测式清理

探测式清理会进行遍历ThreadLocalMap中的散列数组，从开始位置向后探测清理过期数据，将过期的Entry设置为null，沿途中碰到未过期的Entry则将此Entry重新计算哈希值后重新在table散列数组中定位。

为什么碰到未过期的数据要进行重新哈希和定位？
因为当前Entry在之前有可能是因为遇到了哈希冲突才被安排在这里，而此时原本与它发生哈希冲突的Entry可能已经被清理掉了，所以当前Entry需要进行重新哈希和定位判断是否需要放回到它原本该在的地方。
如果重新哈希和定位后再次发生冲突，处理同理是用线性探测找坑位。

### 启发式清理

启发式清理会调用cleanSomeSlots方法，这个方法有两个参数，分别是 i 和 n，i 是开始清理的地方。在 i 处往前每扫描一个Entry，如果该Entry不需要被清理，那么 n 会往右移动一位（即除以2），直到 n 等于0，此时结束扫描。如果在这个过程中扫描到了需要清理的Entry，那么 n 会被设置为table散列数组（即Entry数组）的大小，然后在该处往后进行一段连续段的探测式清理，接着继续回来进行启发式清理。

## 扩容机制

## 注意事项

### 内存泄露问题

在 ThreadLocalMap 中的 Entry 的 key 是对 ThreadLocal 的 `WeakReference` 弱引用，而 value 是强引用。当 ThreadLocalMap 的某 ThreadLocal 对象只被弱引用，GC 发生时该对象会被清理，此时 key 为 null，但 value 为强引用不会被清理。此时 value 将访问不到也不被清理掉就可能会导致内存泄漏。

因此我们使用完 ThreadLocal 后最好手动调用 `remove()` 方法。但其实在 ThreadLocalMap 的实现中以及考虑到这种情况，因此在调用 `set()`、`get()`、`remove()` 方法时，会清理 key 为 null 的记录。

### ThreadLocal 无法给子线程共享父线程的线程副本数据





参考：

[JVM之ThreadLocal及垃圾回收](https://blog.csdn.net/m0_52963553/article/details/126112176)

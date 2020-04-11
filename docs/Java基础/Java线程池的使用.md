# Java线程池的使用

`java.util.concurrent.Executor`是Java中线程池的最顶级接口，代表所有线程池对象。它主要有两个实现类`ThreadPoolExecutor`和`ScheduledThreadPoolExecutor`。以下是线程池的类图：

![](/doc/assets/img/Executor.png)

## 创建线程池

JDK中Executor的实现主要有ThreadPoolExecutor和ScheduledThreadPoolExecutor两个类。可以使用Executors工厂类来创建线程池。Executors提供了工具方法创建5种线程池：

### 固定数量线程池

创建一个固定大小的线程池，线程池维护固定数量的线程，线程存活时间不限。适用于`执行长期任务`，性能较好。

该方法具体操作是设定corePoolSize和maximumPoolSize都为nThreads，keepAliveTime为0（不过时），WorkQueue使用LinkedBlockingQueue无界阻塞队列。

固定数量线程池具有以下特点：

1. 固定数量线程池会提交任务时候创建一个线程，直到线程数达到设定的大小。
2. 线程数量达到设定大小后保持不变，如果其中线程因异常而结束，线程池会补充线程。

```java
Executors.newFixedThreadPool(int nThreads);
```

```java
public static ExecutorService newFixedThreadPool(int nThreads) {
    return new ThreadPoolExecutor(nThreads, nThreads,0L, TimeUnit.MILLISECONDS,
                                  new LinkedBlockingQueue<Runnable>());
}
```

### 单例线程池

创建一个只有一个线程的线程池，其线程存活时间是不限的。使用于按照`顺序执行任务`的场景。

该方法具体操作是设定corePoolSize和maximumPoolSize都为1，keepAliveTime为0（不过时），WorkQueue使用LinkedBlockingQueue无界阻塞队列。

```java
Executors.newSingleThreadExecutor();
```

```java
public static ExecutorService newSingleThreadExecutor() {
    return new FinalizableDelegatedExecutorService(new ThreadPoolExecutor(1, 1,0L, 
					TimeUnit.MILLISECONDS,new LinkedBlockingQueue<Runnable>()));
}
```

### 缓存线程池

```java
Executors.newCachedThreadPool();
```

### 定时线程池

```java
Executors.newScheduledThreadPool(3);
```

### 单例定时线程池

```java
Executors.newSingleThreadScheduledExecutor();
```

## 线程池的执行流程



## 线程池的异常处理



## 线程池的工作队列



## 线程池的拒绝策略



## ThreadPoolExecutor的构造函数与参数

```java
public ThreadPoolExecutor(int corePoolSize,int maximumPoolSize,long keepAliveTime,TimeUnit unit, 
                          BlockingQueue<Runnable> workQueue) 

public ThreadPoolExecutor(int corePoolSize,int maximumPoolSize, long keepAliveTime, TimeUnit unit, 
                          BlockingQueue<Runnable> workQueue, ThreadFactory threadFactory) 

public ThreadPoolExecutor(int corePoolSize,int maximumPoolSize, long keepAliveTime, TimeUnit unit, 
                          BlockingQueue<Runnable> workQueue, RejectedExecutionHandler handler)

public ThreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, 
                          BlockingQueue<Runnable> workQueue, ThreadFactory threadFactory,
                          RejectedExecutionHandler handler) 
```

ThreadPoolExecutor一共有4个构造函数，查看源码可知，前3个构造函数是调用第4个构造函数进行初始化工作的。第4个构造函数一共有7个参数

### corePoolSize

核心池的大小，这个参数跟后面讲述的线程池的实现原理有非常大的关系。在创建了线程池后，默认情况下，线程池中并没有任何线程，而是等待有任务到来才创建线程去执行任务，除非调用了prestartAllCoreThreads()或者prestartCoreThread()方法，从这2个方法的名字就可以看出，是预创建线程的意思，即在没有任务到来之前就创建corePoolSize个线程或者一个线程。默认情况下，在创建了线程池后，线程池中的线程数为0，当有任务来之后，就会创建一个线程去执行任务，当线程池中的线程数目达到corePoolSize后，就会把到达的任务放到缓存队列当中。

### maximumPoolSize

线程池最大线程数，这个参数也是一个非常重要的参数，它表示在线程池中最多能创建多少个线程。

### keepAliveTime

表示线程没有任务执行时最多保持多久时间会终止。

默认情况下，只有当线程池中的线程数大于corePoolSize时，keepAliveTime才会起作用，直到线程池中的线程数不大于corePoolSize，即当线程池中的线程数大于corePoolSize时，如果一个线程空闲的时间达到keepAliveTime，则会终止，直到线程池中的线程数不超过corePoolSize。

如果调用了allowCoreThreadTimeOut(boolean)方法，在线程池中的线程数不大于corePoolSize时，keepAliveTime参数也会起作用，直到线程池中的线程数为0；

### unit

参数keepAliveTime的时间单位。

### workQueue

一个阻塞队列，用来存储等待执行的任务，这个参数的选择也很重要，会对线程池的运行过程产生重大影响，一般来说，这里的阻塞队列有以下几种选择：`ArrayBlockingQueue、LinkedBlockingQueue和SynchronousQueue`。

### threadFactory

线程工厂，主要用来创建线程；

### handler

表示当拒绝处理任务时的策略，有以下四种取值：

ThreadPoolExecutor.AbortPolicy：丢弃任务并抛出RejectedExecutionException异常。 

ThreadPoolExecutor.DiscardPolicy：也是丢弃任务，但是不抛出异常。 

ThreadPoolExecutor.DiscardOldestPolicy：丢弃队列最前面的任务，然后重新尝试执行任务（重复此过程）

ThreadPoolExecutor.CallerRunsPolicy：由调用线程处理该任务 



参考

[java四种线程池的使用](https://www.cnblogs.com/zincredible/p/10984459.html)

[Java并发编程：线程池的使用](https://www.cnblogs.com/dolphin0520/p/3932921.html)

[java线程池 面试题（精简）](https://blog.csdn.net/qq_29373285/article/details/85238728)

[面试必备：Java线程池解析](https://www.cnblogs.com/jay-huaxiao/p/11454416.html)

[Java线程池面试题](https://blog.csdn.net/zhaohong_bo/article/details/89303522)


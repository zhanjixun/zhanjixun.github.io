# Java线程池的使用

`java.util.concurrent.Executor`是Java中线程池的最顶级接口，代表所有线程池对象。它主要有两个实现类`ThreadPoolExecutor`和`ScheduledThreadPoolExecutor`。线程池类关系图如下：

![](/doc/assets/img/Executor.png)

## 创建线程池

JDK中Executor的实现主要有ThreadPoolExecutor和ScheduledThreadPoolExecutor两个类。可以使用Executors工厂类来创建线程池。Executors提供了工具方法创建5种线程池：FixedThreadPool （固定数量线程池）、SingleThreadPool（单例线程池） 、CachedThreadPool （缓存线程池）、ScheduledThreadPool （定时线程池）和 SingleScheduledThreadPool（单例定时线程池） 。

| 线程池         | 适用场景         | 核心线程数 | 最大线程数   | 存活时间 | 工作队列           |
| -------------- | ---------------- | ------------ | ----------------- | ------------- | ------------------- |
| 固定数量线程池 | 执行长期任务     | nThreads     | nThreads          | 0(不过时)     | LinkedBlockingQueue |
| 单例线程池     | 按序执行任务     | 1            | 1                 | 0(不过时)     | LinkedBlockingQueue |
| 缓存线程池     | 大量短期任务     | 0            | Integer.MAX_VALUE | 60s           | SynchronousQueue    |
| 定时线程池     | 延迟或周期性任务 | nThreads     | Integer.MAX_VALUE | 0(不过时)     | DelayedWorkQueue    |
| 单例定时线程池 | 顺序周期性任务   | nThreads     | Integer.MAX_VALUE | 0(不过时)     | DelayedWorkQueue    |

在《阿里巴巴Java开发手册》中明确指出不允许使用Executors的静态工厂构建线程池，为什么呢？

因为在Executors中创建的线程池存在以下弊端：

1. FixedThreadPool 和 SingleThreadPool 的工作队列是无界阻塞队列（LinkedBlockingQueue），队列长度为 Integer.MAX_VALUE ，可能会堆积大量的请求，从而导致OOM问题。
2. CachedThreadPool 、 ScheduledThreadPool 和 SingleScheduledThreadPool 的最大线程数为 Integer.MAX_VALUE ，可能会创建大量线程，导致OOM问题。

正确的创建线程方式应该是使用ThreadPoolExecutor的构造器去创建线程。

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

ThreadPoolExecutor一共有4个构造函数，查看源码可知，前3个构造函数是调用第4个构造函数进行初始化工作的。第4个构造函数一共有7个参数。如下：

| 参数            | 描述                   |
| --------------- | ---------------------- |
| corePoolSize    | 核心线程数量           |
| maximumPoolSize | 最大线程数量           |
| keepAliveTime   | 空闲线程存活时间       |
| unit            | keepAliveTime的单位    |
| workQueue       | 工作队列               |
| threadFactory   | 线程工厂，用于创建线程 |
| handler         | 拒绝策略，有4种取值    |



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


# volatile关键字

Java中的`volatile`关键字主要用于解决多线程环境下的**可见性**和**有序性**问题。

### 保证可见性

Java内存模型（JMM）规定了线程如何与主内存和工作内存交互。每个线程都有自己的工作内存，里面保存了主内存中变量的副本。当线程操作变量时，通常是在自己的工作内存中进行，之后某个时间点才会同步到主内存。非`volatile`变量可能导致其他线程无法及时看到修改后的值。

没有被`volatile`修饰的共享变量何时会从主内存刷新其值？

1. 当线程进入或退出synchronized同步块或方法时。
2. 当线程使用Lock等显式锁进行加锁或解锁操作时。
3. 当线程访问volatile变量时，此时会触发内存屏障，可能影响其他变量的可见性。
4. 线程启动或终止时，可能也会有一些同步，但这点可能需要进一步确认。
5. 其他并发工具类如Thread.join(), CountDownLatch.await()等可能会隐式地引起内存同步。

当变量被声明为`volatile`时，任何线程对该变量的修改会**立即写回主内存**，并且其他线程读取该变量时会**强制从主内存重新加载**最新值。

```java
// 线程A修改flag为true后，线程B能立即看到变化。
volatile boolean flag = false;
```

```java
public static class MyThread extends Thread {

    private boolean isRunning = true;

    @Override
    public void run() {
        System.out.println("线程运行开始....");
        while (isRunning) {
        }
        System.out.println("线程运行结束....");
    }

    public void setRunning(boolean running) {
        isRunning = running;
    }
}

public static void main(String[] args) {
    MyThread myThread = new MyThread();
    myThread.start();
    ThreadUtil.sleep(1000);
    myThread.setRunning(false);
}
```

在这个例子中，主线程修改了isRunning，但是MyThread线程不会重新从主存中获取新值，所以程序会进入死循环状态。

假如在`isRunning`变量上，加一个`volatile`关键字，主线程修改了isRunning，MyThread线程会马上获取到新值。

https://www.cnblogs.com/dxflqm/p/18022824

### 禁止指令重排

编译器和处理器可能对指令进行重排序优化，导致代码执行顺序与预期不一致（如单例模式的双重检查锁问题）。

`volatile`通过插入**内存屏障**（Memory Barrier）禁止指令重排序，确保：

- **写操作前**的所有操作不会重排到写之后。
- **读操作后**的所有操作不会重排到读之前。

### 注意点

#### 不保证原子性

`volatile`无法保证复合操作（如`i++`）的原子性。需用`synchronized`或原子类（如`AtomicInteger`），即使字段被声明为`volatile`，对它的**多步操作**（如`i++`、`i = i + 1`）仍然不是原子的。

```java
volatile int count = 0;
// 线程A和线程B同时执行：
count++;  // 实际是三步操作：读值 → 加1 → 写回
```

若两个线程同时读到`count=0`，各自加1后写回，最终结果可能是`1`而非预期的`2`。

`volatile`仅保证单次读/写操作的原子性（如`count = 5`），但无法保证多步骤操作的原子性。


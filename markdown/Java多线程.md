# Java多线程

## 多线程的概念

为什么使用多线程？

## 线程的创建方式

## 线程的状态

![](../assets/drawio/线程的状态.svg)

## 线程调度

### 线程中断

```java
public static void main(String[] args) {
    Thread thread1 = new Thread(() -> {
        for (int i = 0; i < 10; i++) {
            if (!Thread.currentThread().isInterrupted()) {
                ThreadUtil.sleep(1000);
                System.out.println("线程数数:" + i);
            } else {
                System.out.println("线程被中断了");
                return;
            }
        }
        System.out.println("线程自然结束了");
    });
    thread1.start();
    ThreadUtil.sleep(2000);
    thread1.interrupt();
}
```

## 线程安全

## 线程间通信

## 线程池
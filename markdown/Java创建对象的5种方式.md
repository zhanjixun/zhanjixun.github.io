# Java创建对象的5种方式

| 方式                        | 构造函数         |
| --------------------------- | ---------------- |
| 使用new关键字               | 调用了构造函数   |
| 使用Class.newInstance       | 调用了构造函数   |
| 使用Constructor.newInstance | 调用了构造函数   |
| 使用Clone方法               | 没有调用构造函数 |
| 使用反序列化                | 没有调用构造函数 |

可见，**Java创建实例对象，并不一定必须要调用构造器的。**



关于两种newInstance方法的区别：

1. Class类位于java的lang包中，而Constructor是java反射机制的一部分
2. Class类的newInstance只能触发**无参数的**构造方法创建对象，而Constructor类的newInstance能触发**有参数或者任意参数**的构造方法来创建对象。
3. Class类的newInstance需要其构造方法**是public的或者对调用方法可见的**，而Constructor类的newInstance可以**在特定环境下**调用私有构造方法来创建对象。
4. Class类的newInstance抛出类构造函数的异常，而Constructor类的newInstance包装了一个`InvocationTargetException`异常。


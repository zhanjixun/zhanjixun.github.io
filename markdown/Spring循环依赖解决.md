# Spring循环依赖解决

Spring中有三级缓存，用于存储单例的Bean实例，这三个缓存是彼此互斥的，不会针对同一个Bean的实例同时存储。如果调用getBean，则需要从三个缓存中依次获取指定的Bean实例。读取顺序依次是一级缓存-->二级缓存-->三级缓存。后两个Map其实是“垫脚石”级别的，只是创建Bean的时候，用来借助了一下，创建完成就清掉了

![](..\assets\img\566a6ae0b2936c88.png)

在ApplicationContext.getBean()获取A对象实例的时候，由于容器中还没有A实例，则会去创建A对象，然后发现其依赖了B对象。则会通过ApplicationContext.getBean()去获取B对象，发现B对象也还没有实例则会去创建B对象。然后又发现B对象依赖了A对象，就调用getBean方法去获取A对象，此时A对象已经在spring容器中，属于半成品，会将A对象返回。

> 1. 实例化 A，此时 A 还未完成属性填充和初始化方法（@PostConstruct）的执行，A 只是一个半成品。
> 2. 为 A 创建一个 Bean工厂，并放入到 singletonFactories 中
> 3. 发现 A 需要注入 B 对象，但是一级、二级、三级缓存均为发现对象 B
> 4. 实例化 B，此时 B 还未完成属性填充和初始化方法（@PostConstruct）的执行，B 只是一个半成品
> 5. 为 B 创建一个 Bean工厂，并放入到 singletonFactories 中
> 6. 发现 B 需要注入 A 对象，此时在一级、二级未发现对象A，但是在三级缓存中发现了对象 A，从三级缓存中得到对象 A，并将对象 A 放入二级缓存中，同时删除三级缓存中的对象 A（注意，此时的 A还是一个半成品，并没有完成属性填充和执行初始化方法）
> 7. 将对象 A 注入到对象 B 中
> 8. 对象 B 完成属性填充，执行初始化方法，并放入到一级缓存中，同时删除二级缓存中的对象 B（此时对象 B 已经是一个成品）
> 9. 对象 A 得到对象B，将对象 B 注入到对象 A 中（对象 A 得到的是一个完整的对象 B）
> 10. 对象 A完成属性填充，执行初始化方法，并放入到一级缓存中，同时删除二级缓存中的对象 A



[https://blog.csdn.net/cristianoxm/article/details/113246104](https://blog.csdn.net/cristianoxm/article/details/113246104)


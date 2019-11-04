# 系统化知识体系

数据结构

- 队列
- 集合
- 链表、数组
- 字典、关联数组
- 栈
- 树
  - 二叉树
  - 完全二叉树
  - 平衡二叉树
  - 二叉查找树
  - 红黑树
  - B、B+、B*树
  - LSM树
- 图
- bitSet

算法

- 排序算法
  - 冒泡排序
  - 选择排序
  - 快速排序
  - 插入排序
  - 归并排序
  - 希尔排序
  - 计数排序
  - 基数排序（桶排序）
  - 堆排序
- 二分查找
- 布隆过滤器
- KMP算法
- 深度优先、广度优先
- 贪心算法
- 回溯算法
- 剪枝算法
- 动态规划
- 朴素贝叶斯
- 推荐算法
- 最小生成树算法
- 最短路径算法

JDK基础

- 集合类
- 多线程、高并发
- IO、NIO

JVM

- JVM 内存结构
- HotSpot 虚拟机对象探秘
- 垃圾收集策略与算法
- HotSpot 垃圾收集器
- 内存分配与回收策略
- JVM 性能调优
- 类文件结构
- 类加载的时机
- 类加载的过程
- 类加载器

mybatis

- 整体架构
- 源码解析
- 自写Mybatis

Spring

- ioc
- aop
- tx

Spring MVC

- 11步执行流程图
- 六大组件

SpringBoot

- 自动配置源码解析
- yml文件加载过程
- 手写Stater

SpringCloud

Dubbo

- 分布式概念、分布式模块划分
- Dubbo高可用：容错机制、服务降级、服务限流、多版本控制、多注册中心
- 源码分析：Dubbo的SPI、对Spring配置文件的解析、Provider的服务暴露、consumer的服务消费

Redis

- 安装以及使用，基本命令
- redis五种数据类型及使用场景
- 分布式中使用redis
- 持久化原理及数据失效场景
- redis内存管理：内存分配、内存压缩、过期数据回收策略、内存回收策略LRU/LFU
- redis事务管理
- redis主从复制
- redis哨兵机制
- redis cluster集群
- redis实现分布式锁
- 常见问题：缓存穿透、缓存雪崩、缓存击穿、缓存双写一致性
- redis监控：monitor调试命令、info命令内容、图形化redis监控
- redis与memcached的对比

Nginx

- Nginx的安装、常用命令和配置文件
- 反向代理
- 负载均衡
- 动静分离
- 高可用集群
- Nginx原理

MongoDB

ActiveMQ

RabbitMQ

RocketMQ

kafka

Zookeeper

Netty

MySQL

- 架构执行流程
- SQL语句顺序和解析顺序
- 索引 索引结构
- 锁和事务
- 性能分析
- 主从复制、读写分离、集群

Docker   :   [虚拟化容器技术：Docker](https://blog.csdn.net/zhanjixun/article/details/100701530)

- 基本使用
- 镜像、容器、仓库概念
- docker compose
- docker swarm

Tomcat

Liunx

设计模式

- 设计模式的六大原则
  - 开闭原则：对扩展开放,对修改关闭，多使用抽象类和接口
  - 里氏替换原则：基类可以被子类替换，使用抽象类继承,不使用具体类继承
  - 依赖倒转原则：要依赖于抽象,不要依赖于具体，针对接口编程,不针对实现编程
  - 接口隔离原则：使用多个隔离的接口,比使用单个接口好，建立最小的接口
  - 迪米特法则：一个软件实体应当尽可能少地与其他实体发生相互作用，通过中间类建立联系
  - 合成复用原则：尽量使用合成/聚合,而不是使用继承
- 23种常见设计模式
  - 创建型模式，共五种：
    - 工厂方法模式
    - 抽象工厂模式
    - 单例模式
    - 建造者模式
    - 原型模式
  - 结构型模式，共七种：
    - 适配器模式
    - 装饰器模式
    - 代理模式
    - 外观模式
    - 桥接模式
    - 组合模式
    - 享元模式
  - 行为型模式，共十一种：
    - 策略模式
    - 模板方法模式
    - 观察者模式
    - 迭代子模式
    - 责任链模式
    - 命令模式
    - 备忘录模式
    - 状态模式
    - 访问者模式
    - 中介者模式
    - 解释器模式
- 应用场景

常见场景实现

- SSO单点登录

- 秒杀系统
- 分布式Seesion管理
- 分布式锁
- 分布式事务

参考：

​	[https://github.com/xingshaocheng/architect-awesome]( https://github.com/xingshaocheng/architect-awesome ) 
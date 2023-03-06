## 消息队列有什么优缺点

MQ的优点有很多，总结起来就三点：**解耦**、**异步**和**削峰**。

缺点有以下几个：**降低系统可用性**、**加大系统复杂度**和**一致性问题**

##  各种消息队列的区别

### ActiveMQ

ActiveMQ是使用Java语言开发一款MQ产品。早期很多公司与项目中都在使用。但现在的`社区活跃度`已经很低。现在的项目中已经很少使用了。

### RabbitMQ

RabbitMQ是使用`ErLang语言`开发的一款MQ产品。其吞吐量较Kafka与RocketMQ要低，且由于其不是Java语言开发，所以公司内部对其实现定制化开发难度较大。

### Kafka

Kafka是使用Scala/Java语言开发的一款MQ产品。其最大的特点就是`高吞吐率`，常用于`大数据领域`的实时计算、日志采集等场景。其没有遵循任何常见的MQ协议，而是使用自研协议。对于Spring Cloud Netflix，其仅支持RabbitMQ与Kafka。

### RocketMQ

RocketMQ是使用Java语言开发的一款MQ产品。经过数年阿里双11的考验，性能与稳定性非常高。其没有遵循任何常见的MQ协议，而是使用自研协议。对于Spring Cloud Alibaba，其支持RabbitMQ、Kafka，但提倡使用RocketMQ。

| 关键词     | ActiveMQ | RabbitMQ | Kafka                 | RocketMQ              |
| ---------- | -------- | -------- | --------------------- | --------------------- |
| 开发语言   | Java     | ErLang   | Java                  | Java                  |
| 单机吞吐量 | -        | -        | 百级topic会影响吞吐量 | 千级Topic会影响吞吐量 |
| Topic      |          |          |                       |                       |
| 社区活跃度 | 低       | 高       | 高                    | 高                    |


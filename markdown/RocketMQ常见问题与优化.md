# RocketMQ常见问题

## 避免消息重复消费

## 实现顺序消费

## 如何保证消息不丢失

要保证 100% 消息不丢失，需要从 **发送、存储、消费** 三个环节入手：

### A. 发送端（Producer）

- **同步发送：** 使用 `send(Message msg)` 同步返回结果，并判断 `SendStatus` 是否为 `SEND_OK`。
- **重试机制：** 默认会有 2 次重试，可以适当增加重试次数。

### B. Broker 端（存储）

- **刷盘策略：** 将 `flushDiskType` 从异步刷盘（Async）改为 **同步刷盘（Sync）**。这样消息落盘后才返回成功给 Producer，防止宕机导致内存数据丢失。
- **主备复制：** 部署多主多从集群，并将 `replicationMode` 设置为 **同步复制（Sync Replication）**，确保 Master 和 Slave 都写入成功。

### C. 消费端（Consumer）

- **手动返回状态：** 只有在业务逻辑处理完成后，才返回 `CONSUME_SUCCESS`。
- **避免异步处理：** 不要在监听器内部开启多线程处理消息又立即返回成功，否则如果子线程挂了，消息就丢失了。

## 如何处理消息堆积



[消息队列的十连问，经典永不过期](https://mp.weixin.qq.com/s/ZeJ2_kA9hDDivZXnLq3Ykw)
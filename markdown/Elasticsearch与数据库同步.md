# Elasticsearch与数据库同步

1. **同步更新**

   > 更新数据库时候同时更新ES索引

2. **异步通知**

   > 可以使用消息中间件，先更新数据库，再发布消息到MQ，通知ES进行更新索引

3. **监听binlog**

   > 开启mysql的binlog功能，es监听binlog进行更新索引


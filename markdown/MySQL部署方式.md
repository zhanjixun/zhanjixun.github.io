# MySQL部署方式

### 1. 单机部署 (Single Instance)

这是最基础的方案，直接在一台服务器上安装 MySQL。

- **适用场景**：个人博客、开发测试环境、数据量极小的内部小工具。
- **优点**：部署最简单，成本最低。
- **缺点**：**无高可用**。如果服务器宕机或磁盘损坏，业务立即中断，且存在丢数据风险。

------

### 2. 主从复制 (Master-Slave)

这是生产环境最常用的基础架构。一台主库（Master）负责写，一台或多台从库（Slave）负责读。

- **部署模式**：
  - **一主一从/一主多从**：主库将变更写入 Binlog，从库异步或半同步同步数据。
  - **读写分离**：配合中间件（如 ProxySQL 或 MyCat），让查询去从库，写入去主库。
- **优点**：分担读压力，提供了数据冗余备份。
- **缺点**：主从切换需要手动或配合工具（如 MHA/Keepalived），存在短暂不可用时间。

```shell
docker network create mysql-net
docker run -d --name mysql-master --network mysql-net -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql:8.0 --server-id=1 --log-bin=mysql-bin
docker run -d --name mysql-slave1 --network mysql-net -e MYSQL_ROOT_PASSWORD=root -p 3307:3306 mysql:8.0 --server-id=2 --log-bin=mysql-bin
docker run -d --name mysql-slave2 --network mysql-net -e MYSQL_ROOT_PASSWORD=root -p 3308:3306 mysql:8.0 --server-id=3 --log-bin=mysql-bin

docker exec -it mysql-master mysql -uroot -proot
CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
-- 查看 Master 状态，记下 File 和 Position
SHOW MASTER STATUS;

docker exec -it mysql-slave1 mysql -uroot -proot
docker exec -it mysql-slave2 mysql -uroot -proot

CHANGE MASTER TO 
  MASTER_HOST='mysql-master',
  MASTER_USER='repl',
  MASTER_PASSWORD='repl_password',
  MASTER_LOG_FILE='mysql-bin.000003',
  MASTER_LOG_POS=827;

START SLAVE;

-- 检查状态，看到 Slave_IO_Running 和 Slave_SQL_Running 均为 Yes 即可
SHOW SLAVE STATUS\G
```

------

### 3. 高可用集群方案 (High Availability)

为了解决主从方案“手动切换”的问题，自动化的高可用架构应运而生：

#### ① MGR (MySQL Group Replication)

这是 MySQL 官方目前主推的方案（MySQL 5.7.17+ 推出）。

- **原理**：基于 Paxos 协议的多机协作。只要超过半数节点在线，集群就能正常工作。
- **特点**：**强一致性**，支持单主模式（自动选主）或多主模式。
- **优点**：无缝自动切换，数据一致性极高，不需要第三方高可用件。

#### ② MHA (Master High Availability)

- **原理**：一个外部管理节点监控集群。主库挂了，它会自动选一个从库升为主库。
- **状态**：虽然经典，但目前社区活跃度有所下降，逐渐被 MGR 取代。

#### ③ PXC / Galera Cluster

- **原理**：基于 Galera 协议的多主架构。
- **特点**：**同步复制**。写入一台，三台全部成功才返回。数据绝对一致，但写入延迟受限于网络最慢的那台机器。

------

### 4. 分片与分布式架构 (Sharding)

当数据量达到亿级、单机硬盘和性能撑不住时，需要“分库分表”。

- **部署方案**：
  - **中间件模式**：使用 **MyCat** 或 **ShardingSphere**。应用层无感，由中间件负责把数据路由到不同的物理节点。
  - **NewSQL/分布式数据库**：如 **TiDB**（兼容 MySQL 协议）。它原生支持分布式水平扩展，不需要手动分表。
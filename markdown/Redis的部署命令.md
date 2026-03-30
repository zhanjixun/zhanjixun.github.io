# Redis的部署方式

Redis有四种部署模式，分别是**单机部署**、**主从复制**、**哨兵模式**和**集群模式**。

## 单点部署

```shell
docker run --name mall-redis -d --restart=unless-stopped -p 6379:6379 redis:8.0 redis-server --appendonly yes --protected-mode no
```

## 主从复制

```shell
docker network create redis-net
docker run -d --name redis-master -p 6379:6379 --network redis-net redis:8.0
docker run -d --name redis-slave1 -p 6380:6379 --network redis-net redis:8.0 redis-server --replicaof redis-master 6379
docker run -d --name redis-slave2 -p 6381:6379 --network redis-net redis:8.0 redis-server --replicaof redis-master 6379
```

## 哨兵模式

```shell
docker network create redis-net
docker run -d --name redis-master -p 6379:6379 --network redis-net redis:8.0
docker run -d --name redis-slave1 -p 6380:6379 --network redis-net redis:8.0 redis-server --replicaof redis-master 6379
docker run -d --name redis-slave2 -p 6381:6379 --network redis-net redis:8.0 redis-server --replicaof redis-master 6379

cat > ~/sentinel.conf <<EOF
port 26379
dir /tmp
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF

docker run -d --name redis-sentinel1 --network redis-net -p 26379:26379 -v ~/sentinel.conf:/usr/local/etc/redis/sentinel.conf redis:8.0 redis-sentinel /usr/local/etc/redis/sentinel.conf
docker run -d --name redis-sentinel2 --network redis-net -p 26380:26379 -v ~/sentinel.conf:/usr/local/etc/redis/sentinel.conf redis:8.0 redis-sentinel /usr/local/etc/redis/sentinel.conf
docker run -d --name redis-sentinel3 --network redis-net -p 26381:26379 -v ~/sentinel.conf:/usr/local/etc/redis/sentinel.conf redis:8.0 redis-sentinel /usr/local/etc/redis/sentinel.conf
```

## 集群部署

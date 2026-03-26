# Nacos部署方案

## 单机部署

```shell
docker run -d \
  --name nacos-server \
  -p 8848:8848 \
  -p 9848:9848 \
  -e MODE=standalone \
  nacos/nacos-server:v2.3.2
```

## 集群部署

```shell
mkdir -p ~/config
cat > ~/config/nginx-nacos.conf << 'EOF'
# HTTP 配置（端口 8848）
upstream nacos_http {
    server nacos1:8848;
    server nacos2:8848;
    server nacos3:8848;
}

server {
    listen 8848;
    location / {
        proxy_pass http://nacos_http;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

# gRPC 配置（端口 9848）
upstream nacos_grpc {
    server nacos1:9848;
    server nacos2:9848;
    server nacos3:9848;
}

server {
    listen 9848 http2;   # 必须启用 http2
    location / {
        grpc_pass grpc://nacos_grpc;
        # 可选：设置 gRPC 超时和 keepalive
        grpc_read_timeout 600s;
        grpc_send_timeout 600s;
        grpc_socket_keepalive on;
    }
}
EOF
docker network create nacos-cluster-net

# 下载初始化 SQL
#wget https://raw.githubusercontent.com/alibaba/nacos/develop/distribution/conf/nacos-mysql.sql
wget -O /tmp/nacos-mysql.sql https://github.com/alibaba/nacos/raw/refs/heads/master/distribution/conf/mysql-schema.sql

# 启动 MySQL（使用刚下载的 SQL 初始化数据库）
docker run -d \
  --name mysql-nacos \
  --network nacos-cluster-net \
  -e MYSQL_ROOT_PASSWORD=fkFEegkhkNaN89xS \
  -e MYSQL_DATABASE=nacos \
  -v /tmp/nacos-mysql.sql:/docker-entrypoint-initdb.d/nacos-mysql.sql \
  -p 3306:3306 \
  mysql:8.0

docker run -d \
  --name nginx-nacos \
  --network nacos-cluster-net \
  -p 8848:8848 \
  -p 9848:9848 \
  -v ~/config/nginx-nacos.conf:/etc/nginx/conf.d/nacos.conf \
  nginx:1.26.0

for i in {1..3}; do
  docker run -d \
    --name nacos$i \
    --network nacos-cluster-net \
    -e MODE=cluster \
    -e NACOS_SERVERS="nacos1:8848 nacos2:8848 nacos3:8848" \
    -e SPRING_DATASOURCE_PLATFORM=mysql \
    -e MYSQL_SERVICE_HOST=mysql-nacos \
    -e MYSQL_SERVICE_PORT=3306 \
    -e MYSQL_SERVICE_DB_NAME=nacos \
    -e MYSQL_SERVICE_USER=root \
    -e MYSQL_SERVICE_PASSWORD=fkFEegkhkNaN89xS \
    -e JVM_XMS=512m \
    -e JVM_XMX=512m \
    nacos/nacos-server:v2.3.2
done
```


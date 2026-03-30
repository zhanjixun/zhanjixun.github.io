# RocketMQ部署方式

## 单 Master 模式 

```shell
docker network create rocketmq-net

docker run -d \
  --name rmqnamesrv \
  --network rocketmq-net \
  -p 9876:9876 \
  apache/rocketmq:5.3.0 \
  sh mqnamesrv
  
docker run -d \
  --name rmqbroker \
  --network rocketmq-net \
  -p 10911:10911 -p 10909:10909 \
  -e "NAMESRV_ADDR=rmqnamesrv:9876" \
  -e "JAVA_OPT_EXT=-Xms512m -Xmx512m -Xmn256m" \
  apache/rocketmq:5.3.0 \
  sh mqbroker -n rmqnamesrv:9876 \
  --autoCreateTopicEnable true
  
docker run -d \
  --name rmqdashboard \
  --network rocketmq-net \
  -e "JAVA_OPTS=-Drocketmq.namesrv.addr=rmqnamesrv:9876" \
  -p 8080:8082 \
  apacherocketmq/rocketmq-dashboard:2.1.0

```


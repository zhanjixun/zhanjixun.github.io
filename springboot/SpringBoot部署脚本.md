# SpringBoot部署脚本

**本机部署**

```shell
APP_FILE=/data/jar/app.jar                #修改jar包路径，下面代码无需修改

LOG_FILE=/data/logs/${APP_FILE##*/}.log
pid=`ps -ef|grep ${APP_FILE}|grep -v grep|awk '{print $2}'`
if [ -n "${pid}" ]; then
	echo "正在停止${APP_FILE},进程PID为${pid}"
	kill -9 $pid
fi
echo "启动${APP_FILE}..."
nohup java -jar ${APP_FILE} >${LOG_FILE} 2>&1 &
```

**远程部署**

一般生产环境服务器会跟打包服务器隔离开来，那么需要传输到远程服务器启动

```shell
LOCAL_JAR_FILE=target/app.jar              #修改此处本地jar路径，一般为maven编译后地址
APP_FILE=/data/jar/app.jar                 #修改jar包路径
REMOTE_SERVER=192.168.1.201                #修改远程主机的IP或者hostname  需要开通ssh连接

LOG_FILE=/data/logs/${APP_FILE##*/}.log
echo "正在将${LOCAL_JAR_FILE}传输到${REMOTE_SERVER}的${APP_FILE}..."
scp ${LOCAL_JAR_FILE} root@${REMOTE_SERVER} ${APP_FILE}
pid=`ssh root@${REMOTE_SERVER} ps -ef|grep ${APP_FILE}|grep -v grep|awk '{print $2}'`
if [ -n "${pid}" ]; then
	echo "正在停止${APP_FILE},进程PID为${pid}"
	ssh root@${REMOTE_SERVER}  kill -9 ${pid}
fi
echo "启动${APP_FILE}..."
ssh root@${REMOTE_SERVER} "nohup java -jar ${APP_FILE} >${LOG_FILE} 2>&1 &"
```


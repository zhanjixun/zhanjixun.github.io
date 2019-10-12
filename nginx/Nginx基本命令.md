# Nginx基本命令

```shell
#查看版本
nginx -v
nginx -V

#启动
nginx 
nginx -c /etc/nginx/nginx.conf
service nginx start 

#停止运行
nginx -s top
nginx -s quit
service nginx stop

#重新加载配置文件
nginx -s reload
nginx -s reload -c /etc/nginx/nginx.conf
service nginx reload

#测试配置文件
nginx -t
```


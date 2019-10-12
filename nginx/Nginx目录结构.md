# Nginx目录结构

```shell
/etc/nginx                               #Nginx程序目录
/etc/nginx/nginx.conf                    #主配置文件
/etc/nginx/conf.d                        #附加配置文件目录
/etc/nginx/mime.types                    #媒体资源类型文件（识别请求信息类型）

/usr/sbin/nginx                          #Nginx主程序
/usr/sbin/nginx-debug                    #Nginx运行于调试模式下的住程序文件

/usr/share/nginx                         #默认站点目录
/usr/share/nginx/html                    #默认站点html存放路径
/usr/share/nginx/html/50x.html           #50x状态码相应的html
/usr/share/nginx/html/index.html         #默认首页html

/var/cache/nginx                         #缓存目录

/var/log/nginx                           #日志目录
/var/log/nginx/access.log                #访问日志文件
/var/log/nginx/error.log                 #错误日志文件
```



**nginx主程序目录**

```shell
$ tree /etc/nginx  
/etc/nginx
├── conf.d                                                      #附加配置文件目录
├── fastcgi.conf
├── fastcgi_params
├── koi-utf
├── koi-win
├── mime.types                                                  #nginx的mime文件(识别请求信息类型)
├── modules-available
├── modules-enabled
├── nginx.conf                                                  #nginx的主配置文件
├── proxy_params
├── scgi_params
├── sites-available
│   └── default
├── sites-enabled
│   └── default -> /etc/nginx/sites-available/default
├── snippets
│   ├── fastcgi-php.conf
│   └── snakeoil.conf
├── uwsgi_params
└── win-utf
```



**nginx的默认站点路径**

```shell
$ tree /usr/share/nginx
/usr/share/nginx
├── html                                             #Nginx默认站点目录
│   └── index.html                                   #默认首页文件
├── modules -> ../../lib/nginx/modules
└── modules-available
    ├── mod-http-geoip.conf
    ├── mod-http-image-filter.conf
    ├── mod-http-xslt-filter.conf
    ├── mod-mail.conf
    └── mod-stream.conf
```



**Nginx日志目录**

```shell
$ tree /var/log/nginx
/var/log/nginx
├── access.log             #访问日志文件
└── error.log              #错误日志文件  
```





```shell

```


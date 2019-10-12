# Nginx目录结构

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
├── html
│   └── index.html
├── modules -> ../../lib/nginx/modules
└── modules-available
    ├── mod-http-geoip.conf
    ├── mod-http-image-filter.conf
    ├── mod-http-xslt-filter.conf
    ├── mod-mail.conf
    └── mod-stream.conf
```



```shell

```


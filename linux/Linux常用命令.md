# Linux常用命令

## 磁盘清理命令

**查看文件系统磁盘使用情况**

```shell
df -lh
```

**查看当前目录子文件夹大小**

```shell
#当前文件夹大小
du -sh

#查看子文件夹大小，不递归
du -sh * | sort -n

#查看子文件夹大小，可以指定深度
du -lh --max-depth=1
```

**文件查找**

```shell
 #查找大于500M的文件
 find / -size +500M
 
 
```

## 进程查看命令

**搜索进程**

```shell
ps -ef | grep tomcat
```

**查看端口**

```shell
netsta -an | grep 8080
```


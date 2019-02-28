# 搭建dubbo的分布式运行环境

​	本文记录搭建dubbo分布式运行环境的过程。
​	使用到的技术架构是Nginx作为反向代理，Tomcat作为web容器，zookeeper作为服务注册与发现，mysql作为db层，缓存使用redis以及使用jenkins来持续集成。架构图如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181226121235853.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5qaXh1bg==,size_16,color_FFFFFF,t_70)

[TOC]



## 一、安装Ubuntu虚拟机

### 	1、下载Ubuntu系统镜像

到Ubuntu官网 [https://www.ubuntu.com/download/desktop](https://www.ubuntu.com/download/desktop) 选择自己喜欢的版本下载

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181226123816920.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5qaXh1bg==,size_16,color_FFFFFF,t_70)

### 	2、安装虚拟机

​			基本跟安装其他虚拟机一样，需要注意的是，由于docker运行的容器比较多，需要配置多一点内存，我配置了4GB。	

### 	3、网络配置

​			虚拟机的网络适配器选择桥接模式（直接连接到物理网络）

​			然后在宿主机中看一下ip，我的机子显示如下

​			![在这里插入图片描述](https://img-blog.csdnimg.cn/20181226135445195.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5qaXh1bg==,size_16,color_FFFFFF,t_70)

​			在Ubuntu虚拟机中选择Setting->Network

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181226140044440.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5qaXh1bg==,size_16,color_FFFFFF,t_70)



### 	4、安装中文语言

#### 		4.1、设置软件数据源

​			国内打开Ubuntu的官网比较慢，下载资源要浪费很多时间，这里需要设置一下国内的镜像资源。

​			打开左边任务栏像手提包👜的那个App，右键点击上面那个标签页，在出现的菜单中选择Software & Updates

![在这里插入图片描述](https://img-blog.csdnimg.cn/2018122614203035.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5qaXh1bg==,size_16,color_FFFFFF,t_70)

​			在弹出框中点击Download from那个下拉框 选择Other...找到china 选择其中一个数据源即可，这里选择阿里云。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181226142419402.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5qaXh1bg==,size_16,color_FFFFFF,t_70)

#### 		4.2、设置中文语言

​			打开Setting->Region & Language发现没有中文选项，然后点击下面的Maage Installed Language，然后在跳出来的对话框中点击Install /remove Languages... 勾选Chinese(Simplified)右边的选择框，确定安装语言，下载完后在Language & Support 窗口那个列表中将汉语 拉到最上面，重启即可。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181226142838341.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5qaXh1bg==,size_16,color_FFFFFF,t_70)

### 	5、开放SSH

​		1.检测SSH服务

```
ssh localhost
```

​		如果显示`ssh: connect to host localhost port 22: Connection refused`则还没有启动SSH服务

​		2.安装SSH服务

```shell
sudo apt-get install openssh-server
```

### 	6、关闭密码验证

​		我们安装的这个Ubuntu虚拟机一般是用于开发实验而已，不需要密码保护，不然经常要输入密码很烦。

​		点击右上角的用户->帐号设置->解锁->打开自动登录

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181226150424548.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5qaXh1bg==,size_16,color_FFFFFF,t_70)

## 二、安装docker



## 三、构建自己的Tomcat镜像

​	由于docker hub上面的tomcat镜像不可以设置tomcat user，然后我们有需要设置tomcat帐号来给jenkins访问tomcat，所以需要自制一个tomcat，主要为了设置tomcat user。

1. 创建一个新文件夹mytomcat

2. 到[Tomcat官网](https://tomcat.apache.org/download-70.cgi)下载Tomcat7，复制conf目录下的`server.xml`和`tomcat-users.xml`文件到mytomcat目录中，复制webapps/ROOT目录下的index.jsp到mytomcat目录

3. 修改`server.xml`文件

   在Connector port=8080的节点新增一个属性URIEncoding="UTF-8"，如下已经添加好了，这样可以支持中文访问Tomcat

   ```xml
     <Connector port="8080" protocol="HTTP/1.1"
                  connectionTimeout="20000"
                  redirectPort="8443" URIEncoding="UTF-8" />
   ```

4. 修改`tomcat-users.xml`文件

   修改后文件：

   ```xml
   <?xml version='1.0' encoding='cp936'?>
   <tomcat-users>
   	<role rolename="manager-gui"/>
   	<role rolename="manager-script"/>
   	<role rolename="manager-jmx"/>
   	<role rolename="manager-status"/>
   	<user username="tomcat" password="tomcat" roles="manager-gui,manager-script,manager-jmx,manager-status" />
   </tomcat-users>
   ```

5. 修改`index.jsp`文件

   因为制作成镜像之后会启动多个容器示例，这里修改index.jsp是为了设置一个环境变量来区分出访问的是哪一个Tomcat，找到

   ```html
    <h1>${pageContext.servletContext.serverInfo}</h1>
   ```

   修改为：

   ```html
    <h1>${pageContext.servletContext.serverInfo}:<%=System.getenv("TOMCAT_INSTANCE_ID")%></h1>
   ```

   这样修改后在启动容器的时候需要配置一个环境变量即可区分Tomcat了，例如

   ```
   -e TOMCAT_INSTANCE_ID=web1-tomcat
   ```

   ​

6. 编写Dockerfile文件

   在mytomcat目录下新建一个文件`Dockerfile`，内容：

   ```dockerfile
   #基础镜像：使用jre8
   FROM tomcat:7.0-jre8
   #作者
   MAINTAINER zhanjixun <zhanjixun@qq.com>
   #定义工作目录
   ENV WORK_PATH /usr/local/tomcat/conf
   #定义要替换文件名
   ENV USER_CONF_FILE_NAME tomcat-users.xml
   #定义要替换文件名
   ENV SERVER_CONF_FILE_NAME server.xml
   #删除原文件tomcat-users.xml
   RUN rm $WORK_PATH/$USER_CONF_FILE_NAME
   #复制文件tomcat-users.xml
   COPY  ./$USER_CONF_FILE_NAME $WORK_PATH/
   #删除原文件server.xml
   RUN rm $WORK_PATH/$SERVER_CONF_FILE_NAME
   #复制文件server.xml
   COPY  ./$SERVER_CONF_FILE_NAME $WORK_PATH/
   #定义index.jsp所在目录
   ENV ROOT_PATH /usr/local/tomcat/webapps/ROOT
   #定义要替换文件名
   ENV INDEX_JSP_FILE_NAME index.jsp
   # 删除原来index.jsp文件
   RUN rm $ROOT_PATH/$INDEX_JSP_FILE_NAME
   # 复制新的index.jsp文件
   COPY  ./$INDEX_JSP_FILE_NAME $ROOT_PATH/
   ```

7. 构建docker镜像

   运行命令

   ```
   docker build -t mytomcat:1 .
   ```

   然后耐心登录成功之后

   ```docker
   docker images
   ```

   查看刚刚生成的镜像



## 四、配置和启动Nginx



## 五、启动mysql



## 六、启动zookeeper



## 七、使用dubbo-admin



## 八、jenkins的使用



## 九、启动与接入Redis
# jenkins发布时候替换项目文件

在项目开发过程中，通常会有各种运行环境，比如开发环境、测试环境以及生产环境等。这些环境的一些配置一般都是不一样的，如数据库配置、Redis地址，一些属性配置等。如果我们在发布到不同环境时候都是手动修改配置，难免容易出错，而且这种方式不值得提倡。然后其实像maven也有提供profile功能来灵活切换配置文件，但是这种方式有个不好的地方是需要在项目在存放不同环境的配置，一般来说生产环境的配置信息不对普通开发开放的。

在这样的情况下，结合之前公司的工作经验，自己整理出一个更好的方案。这个方案可以实现以下几点功能：

- 项目部署到不同环境中，能自动切换配置文件
- 重要配置文件可以不对普通开发开放

实现原理：在代码仓库中创建一个额外的仓库来存放不同环境的配置文件，在拉取项目代码后，去仓库拉取配置文件项目，根据不同的环境选择不同目录下的配置文件，替换要发布的项目中的配置文件。然后就是正常的使用maven进行编译，部署等。

## 1、创建配置文件代码仓库

在gitlab中创建一个新项目，用于存放配置文件，目录如下：

- dev
  - db.properties
  - redis.properties
- test
  - db.properties
  - redis.properties
- prd
  - db.properties
  - redis.properties

这里只是大概给个例子，实际按自己项目的需要放置。

## 2、配置jenkins脚本

jenkins的流程是：git clone代码下来之后，执行以下脚本

```shell
#生成临时文件夹
tempdir=profiles$RANDOM

#替换资源文件
git clone git@xxx.git ./$tempdir

#替换资源文件
cp -rf ./$tempdir/prd/* ./src/main/resources

#删除配置文件
rm -rf ./$tempdir

#maven编译，这里的maven命令需要注意自己的maven地址
/usr/share/maven/bin/mvn clean package -Dmaven.test.skip=true

#在这里之后可以使用就打好包了，可以使用jenkins Deploy war/ear to a container 插件部署war到tomcat
#或者是docker相关命令 自己补充
```


# Maven使用记录

[TOC]

# *、使用JDK8及解决中文乱码

```
<properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <java_source_version>1.8</java_source_version>
    <java_target_version>1.8</java_target_version>
    <maven_compiler_plugin_version>3.3</maven_compiler_plugin_version>
</properties>
<build>
    <plugins>
      <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>${maven_compiler_plugin_version}</version>
            <configuration>
                <source>${java_source_version}</source>
                <target>${java_target_version}</target>
                <!--解决乱码问题-->
                <encoding>${project.build.sourceEncoding}</encoding>
            </configuration>
        </plugin>
    </plugins>
</build>
```



# *、打包能运行的Jar

## 1.maven-assembly-plugin插件

在POM.xml文件中添加：

```
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-assembly-plugin</artifactId>
            <version>3.0.0</version>
            <configuration>
                <archive>
                    <manifest>
                        <!--此处指定入口类-->
                        <mainClass>com.demo.App</mainClass>
                    </manifest>
                </archive>
                <descriptorRefs>
                    <!--依赖会一起打包-->
                    <descriptorRef>jar-with-dependencies</descriptorRef>
                </descriptorRefs>
            </configuration>
        </plugin>        
    </plugins>
</build>
```

使用maven命令编译：

> mvn assembly:assembly

编译代码，会在target目录下生成*-with-dependencies.jar的jar，就是我们要的结果。这样编译会将项目的资源文件和所有的依赖一起打包到一个jar中，一站式解决所有问题。

## 2.maven-shade-plugin插件

在POM.xml文件中添加：

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.0.0</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <shadedArtifactAttached>true</shadedArtifactAttached>
        <shadedClassifierName>shaded</shadedClassifierName>
        <transformers>
            <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
            	<!--这里指定入口类-->
                <mainClass>com.demo.App</mainClass>
            </transformer>
        </transformers>
    </configuration>
</plugin>
```

然后在maven打包过程中就会调用这个插件，在tagert目录下生成一个-shaded.jar文件，就是可执行的jar。

> mvn package



# *、使用jetty启动web项目

首先在pom.xml中添加

```
<build>
    <finalName>AppName</finalName>
    <plugins>
        <plugin>
            <groupId>org.eclipse.jetty</groupId>
            <artifactId>jetty-maven-plugin</artifactId>
            <version>9.4.5.v20170502</version>
            <configuration>
                <scanIntervalSeconds>10</scanIntervalSeconds>
                <httpConnector>
                    <!--指定端口号-->
                    <port>8082</port>
                </httpConnector>
            </configuration>
        </plugin>
    </plugins>
</build>
```
然后在项目目录下运行以下命令即可启动web运用。

> mvn jetty:run



# *、生成windows可执行exe包

```
<plugin>
    <groupId>com.akathist.maven.plugins.launch4j</groupId>
    <artifactId>launch4j-maven-plugin</artifactId>
    <version>1.7.25</version>
    <executions>
        <execution>
            <id>l4j-clui</id>
            <phase>package</phase>
            <goals>
                <goal>launch4j</goal>
            </goals>
            <configuration>
                <!--生成exe程序类型，gui用户界面 console控制台-->
                <headerType>gui</headerType>
                <!--到哪里找可运行的jar来制作exe-->
                <jar>${project.build.directory}/${artifactId}-${version}-shaded.jar</jar>
                <!--指定exe文件输出路径-->
                <outfile>${project.build.directory}/${project.name}.exe</outfile>
                <downloadUrl>http://java.com/download</downloadUrl>
                <classPath>
                    <!--这里指定exe文件的入口类-->
                    <mainClass>com.zhanjixun.App</mainClass>
                    <preCp>anything</preCp>
                </classPath>
                <!--指定exe图标资源文件-->
                <icon>src/main/resources/application.ico</icon>
                <jre>
                    <!--指定绑定jre的路径-->
                    <path>/bin/jre</path>
                    <!--最低jre版本-->
                    <minVersion>1.8.0</minVersion>
                    <bundledJre64Bit>true</bundledJre64Bit>
                    <jdkPreference>preferJre</jdkPreference>
                    <runtimeBits>64/32</runtimeBits>
                </jre>
                <!--这里的信息在exe右键属性中能查看-->
                <versionInfo>
                    <fileVersion>1.0.0.0</fileVersion>
                    <txtFileVersion>${project.version}</txtFileVersion>
                    <fileDescription>${project.name}</fileDescription>
                    <copyright>2019 demo.com</copyright>
                    <productVersion>1.0.0.0</productVersion>
                    <txtProductVersion>1.0.0.0</txtProductVersion>
                    <productName>${project.name}</productName>
                    <companyName>demo.com</companyName>
                    <internalName>hasCode</internalName>
                    <!--原始文件名-->
                    <originalFilename>${project.name}.exe</originalFilename>
                </versionInfo>
            </configuration>
        </execution>
    </executions>
</plugin>
```

# *、Mybatis代码生成插件

**配置文件**：`mybatis-generator.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
        PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>
    <!-- 数据库驱动:选择你的本地硬盘上面的数据库驱动包-->
    <classPathEntry
            location="D:\apache-maven-3.6.0\repo\mysql\mysql-connector-java\5.0.5\mysql-connector-java-5.0.5.jar"/>
    <context id="DB2Tables" targetRuntime="MyBatis3">
        <commentGenerator>
            <property name="suppressDate" value="true"/>
            <!-- 是否去除自动生成的注释 true：是 ： false:否 -->
            <property name="suppressAllComments" value="true"/>
        </commentGenerator>
        <!--数据库链接URL，用户名、密码 -->
        <jdbcConnection driverClass="com.mysql.jdbc.Driver"
                        connectionURL="jdbc:mysql://127.0.0.1:3306/test"
                        userId="root"
                        password="123456">
        </jdbcConnection>
        <javaTypeResolver>
            <property name="forceBigDecimals" value="false"/>
        </javaTypeResolver>
        <!-- 生成模型的包名和位置-->
        <javaModelGenerator targetPackage="com.zhanjixun.dto" targetProject="src/main/java">
            <property name="enableSubPackages" value="true"/>
            <property name="trimStrings" value="true"/>
        </javaModelGenerator>
        <!-- 生成映射文件的包名和位置-->
        <sqlMapGenerator targetPackage="mapper" targetProject="src/main/resources">
            <property name="enableSubPackages" value="true"/>
        </sqlMapGenerator>
        <!-- 生成DAO的包名和位置-->
        <javaClientGenerator type="XMLMAPPER" targetPackage="com.zhanjixun.mapper"
                             targetProject="src/main/java">
            <property name="enableSubPackages" value="true"/>
        </javaClientGenerator>

        <!-- 要生成的表 tableName是数据库中的表名或视图名 domainObjectName是实体类名-->
        <table tableName="t_user" domainObjectName="User"
               enableCountByExample="false"
               enableUpdateByExample="false"
               enableDeleteByExample="false"
               enableSelectByExample="false"
               selectByExampleQueryId="false"/>
    </context>
</generatorConfiguration>
```



**maven插件：** `pom.xml`

```xml
<!-- mybatis generator 自动生成代码插件 -->
<plugin>
    <groupId>org.mybatis.generator</groupId>
    <artifactId>mybatis-generator-maven-plugin</artifactId>
    <version>1.3.2</version>
    <configuration>
        <!--指定mybatis-generator.xml所在路径-->
        <configurationFile>${basedir}/src/main/resources/generator/mybatis-generator.xml</configurationFile>
        <!--是否覆盖原有文件-->
        <overwrite>false</overwrite>
        <verbose>true</verbose>
    </configuration>
</plugin>
```

**运行命令：**

> mvn mybatis-generator:generate


# SpringMVC实现Session共享

## 1.`pom.xml`添加项目依赖

注意这个两个项目的版本号不对会触发各种彩蛋，调了好久才调出个没问题的。

```xml
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>2.6.2</version>
</dependency>
<dependency>
    <groupId>org.springframework.session</groupId>
    <artifactId>spring-session-data-redis</artifactId>
    <version>1.3.5.RELEASE</version>
</dependency>
```

## 2.`web.xml`添加拦截器

```xml
<filter>
    <filter-name>springSessionRepositoryFilter</filter-name>
    <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
</filter>
<filter-mapping>
    <filter-name>springSessionRepositoryFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath:spring-session-redis.xml</param-value>
</context-param>
```

## 3.添加`spring-session-redis.xml`配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <context:property-placeholder location="classpath:conf/redis.properties"/>
    <context:annotation-config />

    <bean id="jedisConnectionFactory" class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory">
        <property name="hostName" value="${redis.host}"/>
        <property name="port" value="${redis.port}"/>
        <property name="password" value="${redis.password}"/>
    </bean>

    <bean id="redisTemplate" class="org.springframework.data.redis.core.StringRedisTemplate">
        <property name="connectionFactory" ref="jedisConnectionFactory" />
    </bean>

    <bean id="redisHttpSessionConfiguration"
          class="org.springframework.session.data.redis.config.annotation.web.http.RedisHttpSessionConfiguration"/>

</beans>
```

还有`conf/redis.properties`

```properties
redis.host=localhost
redis.port=6379
redis.password=123456
```



演示代码:[ https://github.com/zhanjixun/spring-session-redis-demo ]( https://github.com/zhanjixun/spring-session-redis-demo )

## 4.测试

项目中添加了jetty插件，这里启动两个jetty用于模拟分布式部署，一个jetty以8081端口启动，另一个以8082端口启动。先打开[http://localhost:8081/home](http://localhost:8081/home) 和 [http://localhost:8082/home](http://localhost:8081/home) ，都被重定向login页面了，先在8081登录跳回home页面，打开http://localhost:8082/home 能够正常显示用户信息，测试通过。
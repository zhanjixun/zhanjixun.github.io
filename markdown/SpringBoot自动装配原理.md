# SpringBoot自动装配原理

自动装配是SpringBoot实现快速开发和部署的核心特性之一，它通过约定大于配置的方式，简化了 Spring 应用的搭建和开发。其核心原理可以总结为以下几个关键点：

1. 应用启动：`@SpringBootApplication`包含 `@EnableAutoConfiguration`
2. 引入自动配置类：`@EnableAutoConfiguration`引入了@Import(`AutoConfigurationImportSelector.class`)
3. 加载候选配置：`AutoConfigurationImportSelector`读取`META-INF/spring.factories`中的配置类
4. 条件过滤：根据 `@Conditional `注解判断哪些配置类生效
5. 注册 Bean：将生效的配置类中的 Bean 注入 Spring 容器中


## @SpringBootApplication

启动类上的 `@SpringBootApplication` 注解是一个复合注解，包含以下三个子注解：

- `@SpringBootConfiguration`：标识这是一个 Spring Boot 配置类
- `@ComponentScan`：扫描当前包及其子包下的组件（如 @Component，@Service 等）
- `@EnableAutoConfiguration`：开启自动配置

```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

## @EnableAutoConfiguration

`@EnableAutoConfiguration`是开启自动配置的功能，包含以下两个关键子注解：

- `@AutoConfigurationPackage`：扫描主配置类（@SpringBootApplication标注的类）
- `@Import(AutoConfigurationImportSelector.class)`：导入自动配置核心类

## AutoConfigurationImportSelector

`AutoConfigurationImportSelector`是自动装配的核心类，它实现`ImportSelector`接口，实现了`selectImports()`方法，从所有引入的依赖JAR包中读取`META-INF/spring.factories`文件，并获取EnableAutoConfiguration键下的配置类列表。方法调用链如下：

```java
@SpringBootApplication                                   // 启动类注解
	@SpringBootConfiguration                             // 标识这是一个配置类
	@ComponentScan                                       // 扫描组件
	@EnableAutoConfiguration                             // 开启自动配置
		@AutoConfigurationPackage                        // 扫描主配置类包及其子包
		@Import(AutoConfigurationImportSelector.class)   
			selectImports()                              
			getAutoConfigurationEntry()                  
			getCandidateConfigurations()                 
			loadFactoryNames()                            
			loadSpringFactories()                        // 查找META-INF/spring.factories文件
```

## META-INF/spring.factories文件

spring.factories文件位于引入的jar包的META-INF目录下，定义了所有可能的自动配置类，例如：

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration
```

## 条件化加载配置类

自动配置类通常带有**条件注解**（`@Conditional` 系列），根据当前应用的类路径、环境变量、Bean 是否存在等条件动态决定是否生效。例如：

- `@ConditionalOnClass`：当类路径存在某个类时生效。
- `@ConditionalOnMissingBean`：当容器中不存在某个 Bean 时生效。
- `@ConditionalOnProperty`：当配置文件中某个属性存在时生效。

```java
@Configuration
@ConditionalOnClass({DataSource.class, EmbeddedDatabaseType.class})
@EnableConfigurationProperties(DataSourceProperties.class)
public class DataSourceAutoConfiguration {
    // 自动配置 DataSource 的代码
}
```

## 自定义Stater

Spring Boot可以通过自定义Stater实现自动引入Bean，实现框架自动装配。步骤如下：

### 添加自动配置类

```java
@Configuration
@ConditionalOnProperty(value = "sms.enable", havingValue = "true", matchIfMissing = true)
@EnableConfigurationProperties({SmsProperties.class})
public class SmsAutoConfiguration {

    @Autowired
    private SmsProperties conf;

    @Bean
    @ConditionalOnMissingBean(SmsService.class)
    public SmsService importService() {
        return new SmsSeriveImpl(conf.getKey());
    }
}

@Data
@ConfigurationProperties(prefix = "sms")
public class SmsProperties {
    private String key;
}

public interface SmsService {
    void send(String content);
}

public class SmsSeriveImpl implements SmsService {
    private final String key;
    public SmsSeriveImpl(String key) {
        this.key = key;
    }    
    @Override
    public void send(String content) {
        System.out.println("发送邮件:" + content);
    }
}
```

### 项目引入stater

```xml
<dependency>
    <groupId>org.example</groupId>
    <artifactId>xxx-stater</artifactId>
    <version>1.0-SNAPSHOT</version>
</dependency>
```

### 添加配置信息

```yaml
sms:
  enable: true
  key: key
```

### 注入Service

```java
@Autowired
private SmsService smsService;

@GetMapping("/postMsg")
public Object postMsg(@RequestParam String text) {
    smsService.send("hello " + text);
    return "success";
}
```

接着请求[http://localhost:8080/postMsg?text=jim](http://localhost:8080/postMsg?text=jim)可以看到返回了success，控制台打印了日志：

```log
[INFO] 2025-04-11 13:57:58.290 [c.z.w.aspect.ControllerLogAspect:47] [b7ff6b73a2f1407f994003dbbfdea990] 请求开始 => IP:0:0:0:0:0:0:0:1 openid:null 地址:GET http://localhost:8080/postMsg 入参:["jim"]
[INFO] 2025-04-11 13:57:58.295 [o.example.service.impl.SmsSeriveImpl:17] [b7ff6b73a2f1407f994003dbbfdea990] 发送邮件:hello jim
[INFO] 2025-04-11 13:57:58.295 [c.z.w.aspect.ControllerLogAspect:51] [b7ff6b73a2f1407f994003dbbfdea990] 请求结束 => 耗时:[13ms] 返回值:success 
```


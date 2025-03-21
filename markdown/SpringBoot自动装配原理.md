# SpringBoot自动装配原理

Spring Boot 的自动装配（Auto-Configuration）是其核心特性之一，它通过约定大于配置的方式，简化了 Spring 应用的搭建和开发。其核心原理可以总结为以下几个关键点：

## @SpringBootApplication注解

启动类上的 `@SpringBootApplication` 注解是一个组合注解，包含以下关键子注解：

- `@EnableAutoConfiguration`：启用自动配置的核心注解。
- `@ComponentScan`：扫描当前包及其子包下的组件（如 @Component，@Service 等）。
- `@SpringBootConfiguration`：标识这是一个 Spring Boot 配置类。

```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

## @EnableAutoConfiguration的作用

`@EnableAutoConfiguration`通过 `@Import`导入了 `AutoConfigurationImportSelector` 类，该类负责加载所有符合条件的自动配置类。关键步骤：

### 加载META-INF/spring.factories

Spring Boot 会在所有依赖的 JAR 中查找 `META-INF/spring.factories`文件，读取`EnableAutoConfiguration` 键下定义的自动配置类列表。

示例（来自 spring-boot-autoconfigure的 spring.factories）：

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,\
...
```

### 条件化加载配置类

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

## 自动装配的流程

1. Spring Boot 启动时加载 `@SpringBootApplication` 注解。

2. `@EnableAutoConfiguration` 触发 `AutoConfigurationImportSelector`。

3. 通过 `SpringFactoriesLoader` 加载所有 `spring.factories` 中的自动配置类。

4. 过滤掉不满足条件注解的配置类。

5. 将剩余的配置类加载到 Spring 容器中，完成自动装配。

## 自定义Stater


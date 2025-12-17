# Spring IoC

Spring 的 **IoC（Inversion of Control，控制反转）** 是 Spring 框架的核心基石。简单来说，它将对象的创建、组装和生命周期管理从代码中抽离出来，交给 Spring 容器来处理。

以下是 Spring IoC 的核心知识点总结：

------

## 核心概念：什么是控制反转？

在传统的编程模式中，如果 A 类需要用到 B 类，通常由 A 手动 `new` 一个 B。而在 IoC 模式下：

- **控制权转移**：对象的创建权从开发者手中转移到了 **Spring 容器**。
- **解耦**：开发者不再需要关心对象是如何创建的，只需要声明“我需要这个对象”，容器就会自动注入。

------

## 核心机制：依赖注入 (DI)

**DI (Dependency Injection)** 是实现 IoC 的具体手段。常见的注入方式有三种：

- **构造器注入**：通过类的构造函数注入依赖，官方推荐（保证依赖不为空）。
- **Setter 注入**：通过 `setXxx` 方法注入，灵活性高。
- **注解注入**：使用 `@Autowired` 或 `@Resource` 自动装配。

------

## Spring 容器类型

Spring 提供了两种主要的容器接口：

- **BeanFactory**：最底层的接口，采用**延迟加载**（用到时才创建对象），适合轻量级应用。
- **ApplicationContext**：`BeanFactory` 的子接口，功能更强大。它支持国际化、事件发布、**预加载**（启动时创建所有 Singleton Bean），是开发中的首选。

------

## Bean 的作用域 (Scope)

在 Spring 中，你可以通过 `@Scope` 注解定义 Bean 的存在形式：

| 作用域 | 描述 | 
| :--- | :--- | 
| **singleton** | **默认**。整个 IoC 容器中只有一个实例。 | 
| **prototype** | 每次获取时都会创建一个新的实例。 | 
| **request** | 每一个 HTTP 请求都会创建一个新实例（仅限 Web）。 | 
| **session** | 每一个 HTTP Session 共享一个实例（仅限 Web）。 |

## Bean 的生命周期

理解生命周期对于排查内存泄漏或初始化逻辑至关重要，主要步骤如下：

1. **实例化** (Instantiate)：内存分配。
2. **属性赋值** (Populate)：依赖注入。
3. **初始化** (Initialization)：
   - 执行 `BeanNameAware`、`BeanFactoryAware` 等接口方法。
   - 执行 `@PostConstruct` 标注的方法。
   - 执行自定义的 `init-method`。
4. **使用中**：Bean 已就绪。
5. **销毁** (Destruction)：执行 `@PreDestroy` 或 `destroy-method`。

## 常用配置方式

- **XML 配置**：传统的 `<bean>` 标签（目前较少使用）。
- **Java 配置类**：使用 `@Configuration` 和 `@Bean`（Spring Boot 主流）。
- **注解扫描**：使用 `@Component`、`@Service`、`@Repository`、`@Controller` 配合 `@ComponentScan`。

## 循环依赖与三级缓存

这是面试中的常客。Spring 通过**三级缓存**解决了 **Singleton** 模式下的部分循环依赖（构造器循环依赖无法解决）：

1. **一级缓存**：存放完整的 Bean。
2. **二级缓存**：存放半成品 Bean（未注入属性）。
3. **三级缓存**：存放 Bean 工厂（用于处理 AOP 代理）。

### 总结

IoC 的本质是**解耦**。它让开发者专注于业务逻辑，而将繁琐的“组件拼装”工作交给 Spring 这位“管家”。



参考：

[spring源码之IOC](https://blog.csdn.net/m0_52963553/article/details/127083276)

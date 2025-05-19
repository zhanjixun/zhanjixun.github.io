# Spring AOP

## 核心概念

连接点（JoinPoint）
程序执行过程中可插入切面的点，例如方法调用、异常抛出、字段修改等。Spring AOP仅支持​**​方法执行​**​类型的连接点。

切点（Pointcut）
定义哪些连接点需要被增强，通过表达式（如`execution`、`within`）匹配目标方法。
​​示例​​：`@Pointcut("execution(* com.example.service.*.*(..))")`

通知（Advice）
切面在特定连接点执行的动作，分为：

- `@Before`：方法执行前触发。
- `@AfterReturning`：方法**正常返回**后触发。
- `@AfterThrowing`：方法**抛出异常**后触发。
- `@After`（Finally）：无论成功或异常，方法结束后触发。
- `@Around`：环绕通知，可完全控制方法的执行流程。

切面（Aspect）
一组通知和切点的模块化封装，使用`@Aspect`注解标记为一个切面类。

目标对象（Target）
被代理的原始对象（未被增强的对象）。

引入（Introduction）
动态为类添加新的接口实现（较少使用）。

## 实现方式

Spring AOP通过**动态代理**实现，有两种代理方式：

### JDK动态代理

默认的方式，需目标类实现接口，代理对象是其接口的实现类。

### CGLIB代理

通过字节码增强生成目标类的子类作为代理对象；无接口时自动使用；

可通过`@EnableAspectJAutoProxy(proxyTargetClass=true)`强制开启。



代理对象的生成时机：应用启动时，由`BeanPostProcessor`对符合条件的Bean生成代理。

## 常用场景

1. **日志记录**：自动记录方法入参、返回值及耗时
2. **事务管理**：通过`@Transactional`注解实现声明式事务（基于AOP）
3. **权限校验**：在方法执行前检查用户权限
4. **性能监控**：统计方法执行时间，定位性能瓶颈
5. **异常处理**：统一处理异常并转换异常类型

## 失效场景

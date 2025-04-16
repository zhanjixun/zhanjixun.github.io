# Spring事务管理

Spring事务的本质其实就是数据库对事务的支持，没有数据库的事务支持，spring是无法提供事务功能的。真正的数据库层的事务提交和回滚是通过`binlog`或者`redo log`实现的。

## 事务的种类

Spring 提供了两种主要的事务管理方式：**编程式事务**和**声明式事务**。其中，声明式事务是 Spring 最推荐的方式，因为它能通过 AOP（面向切面编程）技术提供事务管理，从而减少开发者手动管理事务的复杂性。

### 编程式事务管理

编程式事务管理是侵入性事务管理，使用`TransactionTemplate`或者直接使用`PlatformTransactionManager`。对于编程式事务管理，Spring推荐使用`TransactionTemplate`

```java
// 使用 TransactionTemplate 实现编程式事务
TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
transactionTemplate.execute(status -> {
    // 执行业务逻辑
    try {
        // 如果有任何操作抛出异常，则事务回滚
        // 模拟业务逻辑
        // ...业务逻辑
    } catch (Exception e) {
        status.setRollbackOnly(); // 标记事务回滚
        throw e;
    }
    return null; // 返回值
});
```

### 声明式事务管理

声明式事务是通过 Spring 的 AOP 实现的，开发者只需要通过注解或者 XML 配置声明事务，Spring 会自动为方法生成事务代理。在声明式事务中，事务的边界是由 Spring 框架来管理的，开发者不需要手动控制事务。

常见的声明式事务方式是使用 `@Transactional` 注解：

```java
@Transactional
public void transferMoney(String fromAccount, String toAccount, BigDecimal amount) {
    // 执行业务逻辑
    // 转账操作
    accountRepository.debit(fromAccount, amount);
    accountRepository.credit(toAccount, amount);
}
```
Spring事务属性是描述事务特征的一系列值，主要包括传播行为、隔离级别、只读属性、超时时间和回滚规则。这些属性可以通过@Transactional注解或XML配置进行定义。

```java
@Transactional(
    propagation = Propagation.REQUIRED,        // 传播行为
    isolation = Isolation.READ_COMMITTED,      // 隔离级别
    timeout = 30,                              // 超时时间：事务在指定时间内未完成，则抛出异常
    readOnly = false,                          // 表示该事务只读，不会修改任何数据
    rollbackFor = Exception.class,             // 哪些异常触发事务回滚
    noRollbackFor = ArithmeticException.class  // 哪些异常不应触发回滚
)
```

## 事务的传播行为(Propagation)

事务的传播行为定义了一个事务方法在调用另一个事务方法时的行为。Spring 提供了 7 种事务传播机制，用来处理方法间调用时事务如何传播。

| 传播行为      | 描述                                           |
| ------------- | ---------------------------------------------- |
| REQUIRED      | 默认值，有事务就加入，没有就新建一个           |
| REQUIRES_NEW  | 无论有无事务，都新建一个事务，原事务挂起       |
| SUPPORTS      | 有事务就用，没有就非事务执行                   |
| NOT_SUPPORTED | 无事务方式运行，如果有事务，挂起当前事务       |
| MANDATORY     | 必须在事务中运行，如果没有事务则抛异常         |
| NEVER         | 必须在非事务中运行，有事务就抛异常             |
| NESTED        | 嵌套事务，有事务就创建保存点，没有就创建新事务 |

## 事务的隔离级别

Spring 通过 `@Transactional(isolation = Isolation.XXX)` 提供了对隔离级别的配置支持

数据库隔离级别可参考[MySQL事务管理](markdown/MySQL事务管理)

| 隔离级别                   | 描述                                                         | 脏读 | 不可重复读 | 幻读 |
| -------------------------- | ------------------------------------------------------------ | ---- | ---------- | ---- |
| ISOLATION_DEFAULT          | 这是个 PlatfromTransactionManager 默认的隔离级别，使用数据库默认的事务隔离级别 |      |            |      |
| ISOLATION_READ_UNCOMMITTED | `读未提交`，允许另外一个事务可以看到这个事务未提交的数据     |      |            |      |
| ISOLATION_READ_COMMITTED   | `读已提交`，保证一个事务修改的数据提交后才能被另一事务读取，而且能看到该事务对已有记录的更新 |      |            |      |
| ISOLATION_REPEATABLE_READ  | `可重复读`，保证一个事务修改的数据提交后才能被另一事务读取，但是不能看到该事务对已有记录的更新 |      |            |      |
| ISOLATION_SERIALIZABLE     | `串行化`，一个事务在执行的过程中完全看不到其他事务对数据库所做的更新 |      |            |      |

## 事务失效场景

### 事务方法的访问修饰符不当

**场景描述：**如果在 Spring 中，事务方法被声明为 `private`、`final` 或 `static`，则事务可能不会生效。这是因为 Spring 使用代理机制来管理事务，而这些修饰符会影响代理的生成。spring 要求被代理方法必须是`public`的，在`AbstractFallbackTransactionAttributeSource`类的`computeTransactionAttribute`方法中有个判断，如果目标方法不是 `public`，则`TransactionAttribute`返回 null，即不支持事务。

**解决方案：**将事务方法声明为 `public`，避免使用 `private`、`final` 或 `static` 修饰符。

### 方法内部调用自身的事务方法

**场景描述：**在同一个类中，方法内部调用另一个带有 `@Transactional` 注解的方法时，事务可能不会生效。这是因为 Spring 的事务管理依赖于 AOP 代理机制来实现事务的控制。当一个方法内部直接调用同一类中的另一个方法时，调用的是当前对象的实例方法，而不是通过代理对象进行调用。由于事务管理是通过代理对象的切面实现的，直接调用会导致事务增强失效，事务无法生效。

**解决方案：**为了解决同一类中方法内部调用导致事务失效的问题，可以考虑以下几种解决方案：

1. 使用 `AopContext.currentProxy()` 获取代理对象

2. 使用 `ApplicationContext` 获取代理对象

3. 将事务方法提取到另一个服务类中

### 异常被捕获但未重新抛出

**场景描述：**如果在事务方法中捕获了异常但没有重新抛出，Spring 无法识别异常，事务也不会回滚。

**解决方案：**在捕获异常后，使用 `TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();` 标记事务回滚，或重新抛出运行时异常。

### 使用了错误的事务传播行为

**场景描述：**选择不当的事务传播行为可能导致事务管理不符合预期。例如，使用 `Propagation.NEVER` 这种类型的传播特性不支持事务，如果有事务则会抛异常。

**解决方案：**根据业务需求，选择合适的事务传播行为，默认是 `Propagation.REQUIRED`。

### 事务方法所在类未被 Spring 管理

**场景描述：**如果包含事务方法的类没有被 Spring 容器管理（即没有使用 `@Service`、`@Component` 等注解），则事务注解不会生效。

**解决方案：**确保包含事务方法的类被 Spring 容器管理。

### 异步方法中的事务失效

**场景描述：**在异步方法中，事务可能不会生效，因为异步方法通常在不同的线程中执行，Spring 的事务管理是基于线程的。

**解决方案**：

1. 避免在异步方法中使用声明式事务
2. 强制异步方法开启新事务(`@Transactional(propagation = REQUIRES_NEW)`)，但需注意与原事务的隔离性

### 数据库不支持事务

**场景描述：**某些数据库（如 MySQL 的 MyISAM 存储引擎）不支持事务，即使在代码中配置了事务，数据库也无法提供事务支持。

**解决方案：**使用支持事务的数据库引擎，如 MySQL 的 InnoDB。

### 事务回滚规则未正确配置

**场景描述：**默认情况下，Spring 只对运行时异常（`RuntimeException`）和错误（`Error`）进行回滚。如果抛出的是检查型异常（`Exception`），事务不会回滚。

**解决方案：**在 `@Transactional` 注解中，使用 `rollbackFor` 属性指定需要回滚的异常类型。



https://mp.weixin.qq.com/s/rPMFHSTCRwCfiLMIzWbxFg

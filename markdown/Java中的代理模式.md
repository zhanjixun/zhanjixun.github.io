# Java中的代理模式

## 静态代理

**手动编写代理类**，代理类和被代理类实现同一个接口

**优点**：简单直观

**缺点**：冗余代码多，每个被代理类都需要一个对应的代理类

```java
// 接口
interface UserService {
    void save();
}
// 被代理类
class UserServiceImpl implements UserService {
    public void save() {System.out.println("保存用户");}
}
// 静态代理类
class UserServiceProxy implements UserService {
    private UserService target;
    public UserServiceProxy(UserService target) {this.target = target;}
    public void save() {
        System.out.println("前置操作");
        target.save();  // 调用实际对象的方法
        System.out.println("后置操作");
    }
}
// 使用
UserService target = new UserServiceImpl();
UserService proxy = new UserServiceProxy(target);
proxy.save();
```

## 动态代理

**运行时动态生成代理类**，无需手动编写代理类

**实现方式**：通过 `java.lang.reflect.Proxy` 和 `InvocationHandler` 接口

**优点**：灵活，一个代理类可以代理多个接口

只能代理接口，无法代理类（若需代理类，可用第三方库如 **CGLIB**）。

```java
// InvocationHandler 实现类
class LoggingHandler implements InvocationHandler {
    private Object target;
    public LoggingHandler(Object target) {this.target = target;}
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("方法调用前：" + method.getName());
        Object result = method.invoke(target, args);  // 反射调用实际对象的方法
        System.out.println("方法调用后：" + method.getName());
        return result;
    }
}
// 使用动态代理
public class Demo {
    public static void main(String[] args) {
        UserService target = new UserServiceImpl();
        // 创建代理对象
        UserService proxy = (UserService) Proxy.newProxyInstance(
            target.getClass().getClassLoader(),  // 类加载器
            target.getClass().getInterfaces(),   // 接口列表
            new LoggingHandler(target)           // InvocationHandler
        );
        proxy.save();  // 调用代理方法
    }
}
```


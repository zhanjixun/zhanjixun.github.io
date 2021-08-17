# try-catch-finally-return执行顺序

```java
try {
    //代码1
    //异常
    return 表达式T;
} catch (Exception e) {
    //代码2
    return 表达式C;
} finally {
    //代码3
    return 表达式F;
}
```

正常情况：先try后finally

异常情况：先try执行发生异常语句（发生异常后try后面的代码不执行），然后catch，然后finally

return的顺序：finally > catch (异常情况) 、finally > try (正常情况)

在上面这个例子中，正常情况顺序是：

① 代码1

② 表达式T

③ 代码3

④ 表达式F

⑤ finally的return

异常的顺序是：

① 代码1

② 代码2

③ 表达式C

④ 代码3

⑤ 表达式F

⑥ finally的return


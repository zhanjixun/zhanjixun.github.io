# Java中的String类

`String` 是 Java 语言非常基础和重要的类，提供了构造和管理字符串的各种基本逻辑。它是典型的 `Immutable` 类，被声明成为 `final class`，所有属性也都是 `final` 的。

也由于它的不可变性，类似拼接、裁剪字符串等动作，都会产生新的 `String` 对象。

## 为什么String是不可变的？

`String` 真正不可变有下面几点原因：

1. 保存字符串的数组被 `final` 修饰且为私有的，并且`String` 类没有提供/暴露修改这个字符串的方法。
2. `String` 类被 `final` 修饰导致其不能被继承，进而避免了子类破坏 `String` 不可变。

## 为什么要设计成不可变的？

1. 字符串常量池 (String Pool) 的需求
2. 缓存 HashCode
3. 线程安全
4. 安全性

## 与StringBuffer、StringBuilder的区别

StringBuffer

`StringBuffer` 是为解决上面提到拼接产生太多中间对象的问题而提供的一个类，我们可以用 `append` 或者 `add` 方法，把字符串添加到已有序列的末尾或者指定位置。

`StringBuffer` 本质是一个线程安全的可修改字符序列，它保证了线程安全，也随之带来了额外的性能开销，所以除非有线程安全的需要，不然还是推荐使用它的后继者，也就是 `StringBuilder`。

StringBuilder

`StringBuilder` 是 Java 1.5 中新增的，在能力上和 `StringBuffer` 没有本质区别，但是它去掉了线程安全的部分，有效减小了开销，是绝大部分情况下进行字符串拼接的首选。

# Java集合类

| 类                   | 实现原理                                | 线程安全   | 是否有序 | Null元素                      |
| -------------------- | --------------------------------------- | ---------- | -------- | ----------------------------- |
| ArrayList            | 数组（自动扩容）                        | 非线程安全 | 插入顺序 | 允许                          |
| LinkedList           | 双向链表，支持高效插入/删除             | 非线程安全 | 插入顺序 | 允许                          |
| Vector               | 类似ArrayList，方法用`synchronized`修饰 | 线程安全   | 插入顺序 | 允许                          |
| CopyOnWriteArrayList | 写时复制（每次修改创建新数组）          | 线程安全   | 插入顺序 | 允许                          |
|                      |                                         |            |          |                               |
| HashSet              | 基于`HashMap`实现                       | 非线程安全 | 无序     | 允许1个                       |
| LinkedHashSet        | 基于`LinkedHashMap`，维护插入顺序链表   | 非线程安全 | 插入顺序 | 允许                          |
| TreeSet              | 基于红黑树，元素自然排序或自定义比较器  | 非线程安全 | 排序顺序 | 不允许                        |
|                      |                                         |            |          |                               |
| HashMap              | 数组+链表/红黑树（JDK8+）               | 非线程安全 | 无序     | 允许（1个null键，多个null值） |
| LinkedHashMap        | 继承`HashMap`，维护插入/访问顺序链表    | 非线程安全 | 插入顺序 | 允许（1个null键，多个null值） |
| TreeMap              | 基于红黑树，键自然排序或自定义比较器    | 非线程安全 | 键排序   | 不允许（键和值都不能为null）  |
| Hashtable            | 类似`HashMap`，方法用`synchronized`修饰 | 线程安全   | 无序     | 不允许（键和值都不能为null）  |
| ConcurrentHashMap    | 分段锁（JDK7）或CAS+红黑树（JDK8+）     | 线程安全   | 无序     | 不允许（键和值都不能为null）  |

**详细说明**

**List**

- [ArrayList](markdown/ArrayList源码解析.md)：动态数组实现，随机访问快（O(1)），插入/删除慢（O(n)）。
- **LinkedList**：双向链表实现，插入/删除快（O(1)），随机访问慢（O(n)）。
- **Vector**：线程安全的动态数组，性能低于`ArrayList`，已逐渐被替代。
- **CopyOnWriteArrayList**：写操作复制新数组，读无锁，适合读多写少场景。

**Set**

- **HashSet**：基于`HashMap`，元素唯一性通过`hashCode()`和`equals()`保证。
- **LinkedHashSet**：在`HashSet`基础上维护插入顺序链表。
- **TreeSet**：基于红黑树，支持自然排序或自定义比较器。

**Map**

- **HashMap**：哈希表实现，允许null键和null值，非线程安全。
- **LinkedHashMap**：在`HashMap`基础上维护插入或访问顺序链表。
- **TreeMap**：红黑树实现，键有序。
- **Hashtable**：线程安全但性能低，不允许null键/值。
- **ConcurrentHashMap**：高并发场景下的线程安全哈希表，优于`Hashtable`。
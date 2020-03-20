# ArrayList和LinkList的区别

## 一、实现原理

- ArrayList基于数组实现，并且实现了`RandomAccess`接口，支持快速随机访问存储的元素，优点是查询速度快，缺点是增删慢
- LinkedList基于链表实现，查询速度慢，增删快


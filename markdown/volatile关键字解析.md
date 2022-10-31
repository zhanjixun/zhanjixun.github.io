# volatile关键字解析

volatile变量可以确保线性关系，即写操作会发生在后续的读操作之前，但它不能保证原子性。例如用volatile修饰count变量，那么count++操作就不是原子性的。

# ArrayList源码解析

## 类声明

```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
```

ArrayList 实现了 List 接口，是顺序容器，即元素存放的数据与放进去的顺序相同，允许放入`null`元素。

ArrayList 实现了`RandomAccess`，说明 ArrayList 支持随机下标访问。

![](/doc/assets/img/ArrayList.png)

## 成员对象

```java
//默认的容量为10
private static final int DEFAULT_CAPACITY = 10;

private static final Object[] EMPTY_ELEMENTDATA = {};

private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

//核心，用于存放数据的对象数组
transient Object[] elementData; 

//集合元素的个数
private int size;

//记录这个list结构修改的次数
protected transient int modCount = 0;
```

![](/doc/assets/img/1712475c04e43954.png)

## 构造器

```java
//通过参数指明初始化数组的长度
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: " + initialCapacity);
    }
}
//按默认的容量初始化数组
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}

public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {        
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        this.elementData = EMPTY_ELEMENTDATA;
    }
}
```

ArrayList有三个构造器，可以指定初始化数组长度调用`ArrayList(int initialCapacity)`;如果调用无参构造器，会初始化一个空的数组，当第一次`add()`的时候会扩容到默认容量大小（10）；还有一个构造器可以传入一个集合，将其中的元素复制到这个新创建的ArrayList中。

## 扩容机制

### 自动扩容

```java
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}

private void ensureCapacityInternal(int minCapacity) {
    ensureExplicitCapacity(calculateCapacity(elementData, minCapacity));
}

private static int calculateCapacity(Object[] elementData, int minCapacity) {
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        return Math.max(DEFAULT_CAPACITY, minCapacity);
    }
    return minCapacity;
}

private void ensureExplicitCapacity(int minCapacity) {
    modCount++;
    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
```

 当ArrayList在调用`add()`方法的时候，会先检查`size + 1`有没有超过数组容量。如果超过`最小所需容量`超过当前对象数组的长度，则触发扩容，即是调用`grow()`方法。

```java
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```

其中，最关键的语句就是`int newCapacity = oldCapacity + (oldCapacity >> 1);`，这个语句计算出扩容后的数组长度。右移运算符相当于$oldCapacity /(2^1)$，即是扩容后的容量是原来容量的`1.5`倍。



上面提到的`add()` 方法是无参数的方法，直接将元素插入到末尾中。它有个重载函数，能够指定位置插入元素。

```java
public void add(int index, E element) {
    rangeCheckForAdd(index);

    ensureCapacityInternal(size + 1);  // Increments modCount!!
    System.arraycopy(elementData, index, elementData, index + 1,size - index);
    elementData[index] = element;
    size++;
}
```

具体实现跟无参`add()`相似，主要是`System.arraycopy(elementData, index, elementData, index + 1,size - index);`，相当于将`index`后的元素整体后移一个位置，然后再`elementData[index] = element;`。

### 手动扩容

默认地，ArrayList会在当数组长度不够用的时候触发扩容。但是频繁的扩容会造成性能的下降，如果我们预先知道ArrayList要存放多少数据，通过构造函数来指定数组容量，或者手动调用扩容函数`ensureCapacity()`。

```java
public void ensureCapacity(int minCapacity) {
    int minExpand = (elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA) ? 0 : DEFAULT_CAPACITY;

    if (minCapacity > minExpand) {
        ensureExplicitCapacity(minCapacity);
    }
}
```

通过手动调用扩容函数，会一次性的扩容到目标容量，避免频繁触发扩容机制。

## 移除元素

```java
public E remove(int index) {
    rangeCheck(index);

    modCount++;
    E oldValue = elementData(index);

    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,numMoved);
    elementData[--size] = null; // clear to let GC do its work

    return oldValue;
}
```

移除元素的实现非常巧妙，大体思想是`把要移除的元素后面的元素整体向前移动一个位置`。

```java
public boolean remove(Object o) {
    if (o == null) {
        for (int index = 0; index < size; index++)
            if (elementData[index] == null) {
                fastRemove(index);
                return true;
            }
    } else {
        for (int index = 0; index < size; index++)
            if (o.equals(elementData[index])) {
                fastRemove(index);
                return true;
            }
    }
    return false;
}
```

重载函数通过元素来移除的方法实现方式就是`线性查找法`，查找到后快速删除，需要注意的是对象的比较是`equals`方法。

## 获取元素

```java
public E get(int index) {
    rangeCheck(index);
    return elementData(index);
}
```

获取元素的方法非常简单，因为ArrayList基于数组实现，也实现了`RandomAccess`接口，所以直接使用下标即可获取到元素，当然要先判断下标是否越界。

## 修改元素

```java
public E set(int index, E element) {
    rangeCheck(index);
    E oldValue = elementData(index);
    elementData[index] = element;
    return oldValue;
}
```

修改元素的方法也非常简单，判断数组下标没越界后直接用下标修改元素即可。

## 清空集合

```java
public void clear() {
    modCount++;

    // clear to let GC do its work
    for (int i = 0; i < size; i++)
        elementData[i] = null;

    size = 0;
}
```

清空集合，其实主要把size置为0即可，遍历元素置为null是为了gc回收。

## 总结

通过上面的源码分析可以知道：

- ArrayList基于数组实现，底层数据存放在`Object[] elementData`中。
- ArrayList实现`RandomAccess`接口，支持随机下标访问。
- `元素增删慢`，因为需要扩容和移动数组。
- `元素查改快`，因为可以使用下标访问。
- 元素可重复，可以为NULL。

后续：[深入ArrayList看fast-fail机制](https://www.cnblogs.com/myseries/p/10877362.html)
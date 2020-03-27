# Java实现二分查找算法

## 一、算法原理

二分査找就是折半查找，其基本思想是：是在`有序数组`中查找某一特定元素的搜索算法。搜素过程从数组的中间元素开始，如果中间元素正好是要查找的元素，则搜素过程结束；如果某一特定元素大于或者小于中间元素，则在数组大于或小于中间元素的那一半中查找，而且跟开始一样从中间元素开始比较。如果在某一步骤数组 为空，则代表找不到。这种搜索算法每一次比较都使搜索范围缩小一半。折半搜索每次把搜索区域减少一半，时间复杂度为$Ο(logn)$ 。

## 二、代码实现

### 1 ) 递归实现

```java
public static int binarySearch(int[] arr,int low,int high,int key) {
    int mid = (low + high)/2;
    if(arr[mid] == key) {        
        return mid;
    }
    //查找结束
    if(low > high) {
        return -1;
    }
    //折半到大值区内
    if(key > arr[mid]) {
        return binarySearch(arr,mid+1,high,key);
    }  
    //折半到小值区域内
    if(key < arr[mid]) {
        return binarySearch(arr,low,mid-1,key);
    }
    return -1;
}
```

### 2) 顺序实现

```java
public static int binarySearch(int[] arr,int key) {
	int low  = 0;
    int high = arr.length; 
    while(low <= high) {
        int mid = (low + high)/2;
        if(key == arr[mid]) {
            return mid;
        } else if(key > arr[mid]){
            low  = mid + 1;
        } else if(key < arr[mid]){
            high = mid - 1;
        }
    }
    return -1;
}
```


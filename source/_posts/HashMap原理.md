---
title: HashMap原理
date: 2021-03-24 18:52:34
categories:
- Java
 - HashMap
tags:
- Java
 - HashMap
---


<!-- more -->

## HashMap 

## 第一部分：基础入门

### 1. 数组的优势劣势

<img src="HashMap原理/image-20210325112849639.png" alt="image-20210325112849639" style="zoom:50%;" />

数组的内存是连续的，每一块空间是一样大的。

优势：索引速度快，数组都是有index下标的，只要拿到数组的引用，就可以根据index快速访问到指定的位置。

劣势：因为Java中的内存申请完之后大小是固定的，想插入新的数据只能申请一个块更大的内存空间，将旧数组的数据导入新数组后再插入新数据，不灵活且浪费性能



### 2. 链表的优势劣势

<img src="HashMap原理/image-20210325113508084.png" alt="image-20210325113508084" style="zoom:50%;" />

链表在内存中不是一段连续的空间，每一块内存都有一块小空间去保留下一块内存的地址。

优势：插入速度快，只要修改内存存储的指向下一个内存的引用就行了。

劣势：索引速度慢，链表不存在index下标，只能从头元素（Head）开始，挨个查存储的指向下一块内存地址的引用。

### 3.整合两者数据结构的优势：散列表

![image-20210325114151322](HashMap原理/image-20210325114151322.png)

数组里保存的数据是链表，这就是散列表。



### 4.散列表的特点

整合了俩者的优势，既可以利用数组的优势，index快速查找，也可以利用链表的优势快速扩容。

### 5. Hash是什么

Hash ，也成散列，Hash英文本意即为切碎。

基本原理：把**任意长度**的输入通过Hash算法变成**固定长度**的输出。

这个**映射规则**就是对应的接口，而原始数据**映射后的二进制串**就是Hash值。



Hash的特点：

1. 从Hash值不可以**反向推导**出原始数据。
2. 输入数据的**微小变化**会得到完全不同的hash值，相同的数据会得到相同的值。
3. Hash算法的执行效率要**高效**，长的文本也能快速 地计算出Hash值。
4. Hash算法的冲突概率要小。



由于Hash的原理是将输入空间的值映射成Hash空间内，而Hash值的空间远小于输入空间。

根据抽屉原理，一定会存在不同的输入背映射成相同输出的情况。





抽屉原理：**十个**苹果放进九个抽屉里，无论怎么放，总有一个抽屉**不少于两个**苹果。



## 第二部分：HashMap原理简介

### 1.HashMap的继承体系

![image-20210325145444000](HashMap原理/image-20210325145444000.png)

### 2. Node的数据结构分析

HashMap的静态内部类，实现了Map.Entry接口

- hash：存储key 的hash值，key获取hash值后会经过一次扰动再赋值给hash，和直接调用HashCode方法得到的结果不同。
- key，value：就是我们put进来的key-value，我们存的key-value格式的数据都会封装成 Node结构的元素存入散列表。
- next：Hash会碰撞，碰撞后无法存入数组（因为数组中不能存入两个元素），所以只能将数据链起来形成链 表。



```java
  /**
     * Basic hash bin node, used for most entries.  (See below for
     * TreeNode subclass, and in LinkedHashMap for its Entry subclass.)
     */
    static class Node<K,V> implements Map.Entry<K,V> {
        final int hash;
        final K key;
        V value;
        Node<K,V> next;

        Node(int hash, K key, V value, Node<K,V> next) {
            this.hash = hash;
            this.key = key;
            this.value = value;
            this.next = next;
        }

        public final K getKey()        { return key; }
        public final V getValue()      { return value; }
        public final String toString() { return key + "=" + value; }

        public final int hashCode() {
            return Objects.hashCode(key) ^ Objects.hashCode(value);
        }

        public final V setValue(V newValue) {
            V oldValue = value;
            value = newValue;
            return oldValue;
        }

        public final boolean equals(Object o) {
            if (o == this)
                return true;
            if (o instanceof Map.Entry) {
                Map.Entry<?,?> e = (Map.Entry<?,?>)o;
                if (Objects.equals(key, e.getKey()) &&
                    Objects.equals(value, e.getValue()))
                    return true;
            }
            return false;
        }
    }
```

接口 Map.Entry

```java
    interface Entry<K, V> {
        /**
         * Returns the key corresponding to this entry.
         *
         * @return the key corresponding to this entry
         * @throws IllegalStateException implementations may, but are not
         *         required to, throw this exception if the entry has been
         *         removed from the backing map.
         */
        K getKey();

        /**
         * Returns the value corresponding to this entry.  If the mapping
         * has been removed from the backing map (by the iterator's
         * {@code remove} operation), the results of this call are undefined.
         *
         * @return the value corresponding to this entry
         * @throws IllegalStateException implementations may, but are not
         *         required to, throw this exception if the entry has been
         *         removed from the backing map.
         */
        V getValue();

        /**
         * Replaces the value corresponding to this entry with the specified
         * value (optional operation).  (Writes through to the map.)  The
         * behavior of this call is undefined if the mapping has already been
         * removed from the map (by the iterator's {@code remove} operation).
         *
         * @param value new value to be stored in this entry
         * @return old value corresponding to the entry
         * @throws UnsupportedOperationException if the {@code put} operation
         *         is not supported by the backing map
         * @throws ClassCastException if the class of the specified value
         *         prevents it from being stored in the backing map
         * @throws NullPointerException if the backing map does not permit
         *         null values, and the specified value is null
         * @throws IllegalArgumentException if some property of this value
         *         prevents it from being stored in the backing map
         * @throws IllegalStateException implementations may, but are not
         *         required to, throw this exception if the entry has been
         *         removed from the backing map.
         */
        V setValue(V value);

       //... 还有其它方法先不看
    }

```



### 3. 底层数据结构介绍

它的结构就是数组+链表+红黑树

- 最外层是一个Node数组结构，不指定长度的话默认初始化长度为16。

- 无冲突发生时链表只存储一个数据，发生冲突时数组的同位会形成一个链表。

- 当链表长度超过8，且HashMap中所有元素数量超过64时，链表会升级成红白树。（Jdk1.8之后才会将链表升级为红黑树）





<img src="HashMap原理/image-20210325152127750.png" alt="image-20210325152127750" style="zoom:50%;" />

### 4. put数据原理分析

![image-20210325165314183](HashMap原理/image-20210325165314183.png)

1. map.put(“key值”,"value值")

2. key值取得Hash值

3. Hash值经过**扰动**函数，使此Hash值更散列。

4. 构造出Node对象 （Hash，Key，Value，Next）

5. 使用路由算法寻找Node存放在数组的位置路由公式：

   `数组长度 与上 node的hash值`

   table（数组）的长度一定是2的次方数比如 2，16，32，64，

   数组的长度转换成二进制 ,比如:

   16-1 =15 转二进制 => 1111

   32-1 =31 转二进制 => 11111

   (table.length - 1) & node hash

   (16-1) &1122 => 

   B0000 0000 1111 & B0100 00110 0010 => B0010 =>2

   我们使用24位表示法，也只有后门四位是1，

   进行 与 &操作的时候前面8位都变成0了，只有后四位和hash的与 &操作结果生效，转换成10进制为2

   所以存储的位置为index = 2 

### 5.什么是Hash碰撞

接着上步的操作

假如hashtable（数组）的长度不变 ，新的Node转换成的hash值后四位还是0010（当然Hash值也有完全一样的可能）

`B0000 0000 1111` & `B前8位改变，后四位刚巧还是 0010` 

由于前8位是0，与的结果还是0，只有后四位参与了运算，这后四位刚好和上一步的结果一样。

与的结果就仍然是 0010 ,转成10进制还是2，两个Node就会在寻址操作中存入同一个数组元素，这就发生了Hash碰撞。

### 6.什么是链化



### 7.为什么引入红黑树



### 8. HashMap扩容原理





## 第三部分： 源码



 ### 1.HashMap 核心属性分析

 ### 2.  构造方法分析

 ### 3.  


---
title: 【剑指offer01】
date: 2021-02-19 16:26:58
categories:
- 数据结构与算法
- 剑指offer
tags:
- 数据结构与算法
- 剑指offer
---
## 整数



## 数组

### 数组中重复的数字

在一个长度为n的数组里的所有数字都在0到n-1的范围内。 数组中某些数字是重复的，但不知道有几个数字是重复的。也不知道每个数字重复几次。请找出数组中第一个重复的数字。 例如，如果输入长度为7的数组{2,3,1,0,2,5,3}，那么对应的输出是第一个重复的数字2。

返回描述：

如果数组中有重复的数字，函数返回true，否则返回false。

如果数组中有重复的数字，把重复的数字放到参数duplication[0]中。（ps:duplication已经初始化，可以直接赋值使用。）

<!--more-->

#### 方法一：哈希+遍历

题目中含有**重复**的字眼，第一反应应该想到哈希，set。这里我们用哈希来解。
算法步骤：

1. 新建一个HashSet对象

2. 遍历数组，如果Set中包含此数，则返回True，否则继续循环

3. 若直到循环结束没有遇到Set中包含的数据，则数组没有重复的数

代码如下：

```java
  public boolean duplicate(int numbers[],int length,int [] duplication) {
      if(numbers==null||numbers.length==0){
            return false;
        }
        Set<Integer> set = new HashSet<>();
        //set.add(numbers[0]);
        for (int i = 0; i < numbers.length; i++) {
            if (set.contains(numbers[i])){
                duplication[0]=numbers[i];
                return true;
            }else {
                set.add(numbers[i]);
            }
        }
    
        return false;
    }
```

时间复杂度：O(N)
空间复杂度：O(N)

#### 方法二：in-place算法 (这个算法算出的不是第一个重复的数，是任意的)

方法一中的一个条件我们没有用到。也就是数据的范围是0-n-1。所以我们可以这么做：

1. 设置一个指针i指向开头0，

2. 对于arr[i]进行判断，如果arr[i] == i， 说明下标为i的数据**正确的放在了该位置上**，让i++

3. 如果arr[i] != i, 说明没有正确放在位置上，那么我们就把arr[i]放在正确的位置上，也就是交换
   arr[i] 和arr[arr[i]]。交换之后，如果arr[i] ！= i, 继续交换。

4. 如果交换的过程中，arr[i] == arr[arr[i]]，说明遇到了重复值，返回即可。
   如下图：
   
   ![image-20210220182656143](【剑指offer01】-数组/image-20210220182656143.png)


   ```java
public boolean duplicate(int[] nums, int length, int[] duplication) {
    if (nums == null || length <= 0)
        return false;
    for (int i = 0; i < length; i++) {
        while (nums[i] != i) {
            if (nums[i] == nums[nums[i]]) {
                duplication[0] = nums[i];
                return true;
            }
            swap(nums, i, nums[i]);
        }
    }
    return false;
}

private void swap(int[] nums, int i, int j) {
    int t = nums[i];
    nums[i] = nums[j];
    nums[j] = t;
}

   ```

   

时间复杂度：O(N)
空间复杂度：O(1)



## 链表

涉及到链表的操作，一定要在纸上把过程先画出来，再写程序。

### 从尾到头打印链表

- 给出一个链表，需要我们从尾部到头部打印出这个链表的所有的节点的权值。

![image-20211027000327775](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20211027000327775.png)

#### 非递归：

listNode 是链表，只能从头遍历到尾，但是输出却要求从尾到头，这是典型的"先进后出"，我们可以想到栈！
ArrayList 中有个方法是 add(index,value)，可以指定 index 位置插入 value 值
所以我们在遍历 listNode 的同时将每个遇到的值插入到 list 的 0 位置，最后输出 listNode 即可得到逆序链表

时间复杂度：![img](https://www.nowcoder.com/equation?tex=O(n)&preview=true)
空间复杂度：![img](https://www.nowcoder.com/equation?tex=O(n)&preview=true)

```java
import java.util.*;
public class Solution {
    public ArrayList<Integer> printListFromTailToHead(ListNode listNode) {
        ArrayList<Integer> list = new ArrayList<>();
        ListNode tmp = listNode;
        while(tmp!=null){
            list.add(0,tmp.val);
            tmp = tmp.next;
        }
        return list;
    }
}
```

#### 递归

既然非递归都实现了，那么我们也可以利用递归，借助系统的"栈"帮忙打印

```java
import java.util.*;
public class Solution {
    ArrayList<Integer> list = new ArrayList();
    public ArrayList<Integer> printListFromTailToHead(ListNode listNode) {
        if(listNode!=null){
            printListFromTailToHead(listNode.next);
            list.add(listNode.val);
        }
        return list;
    }
}
```

时间复杂度：![img](https://www.nowcoder.com/equation?tex=O(n)&preview=true)
空间复杂度：![img](https://www.nowcoder.com/equation?tex=O(n)&preview=true)

### 反转链表

#### 非递归

双指针

1. 定义两个指针： pre 和 cur ；pre 在前 cur在后。
2. 每次让 pre 的 next指向 cur ，实现一次局部反转
3. 局部反转完成之后，pre 和 cur 同时往前移动一个位置
4. 循环上述过程，直至 pre 到达链表尾部

下图 中 cur和pre 画反了



![](https://pic.leetcode-cn.com/9ce26a709147ad9ce6152d604efc1cc19a33dc5d467ed2aae5bc68463fdd2888.gif)

复杂度：

- 时间复杂度：O(n)，假设 n** 是列表的长度，时间复杂度是 O(n)。
- 空间复杂度：O(1)。

```java
class Solution {
    public ListNode reverseList(ListNode head) {
        ListNode prev = null;
        ListNode curr = head;
        while (curr != null) {
            ListNode nextTemp = curr.next;
            curr.next = prev;
            prev = curr;
            curr = nextTemp;
        }
        return prev;
    }
}
```



#### 递归

1. 使用递归函数，一直递归到链表的最后一个结点，该结点就是反转后的头结点，记作 ret .
2. 此后，每次函数在返回的过程中，让当前结点的下一个结点的 next 指针指向当前节点。
3. 同时让当前结点的 next指针指向 NULL，从而实现从链表尾部开始的局部反转
4. 当递归函数全部出栈后，链表反转完成。

![](https://pic.leetcode-cn.com/8951bc3b8b7eb4da2a46063c1bb96932e7a69910c0a93d973bd8aa5517e59fc8.gif)

```java
class Solution {
    public ListNode reverseList(ListNode head) {
        if (head == null || head.next == null) {
            return head;
        }
        ListNode ret = reverseList(head.next);
        head.next.next = head;
        head.next = null;
        return ret;
    }
}

```

复杂度：

时间复杂度：O(n)，假设n 是列表的长度，那么时间复杂度为 O(n)。
空间复杂度：O(n)，由于使用递归，将会使用隐式栈空间。递归深度可能会达到 n 层。

#### 删除链表的节点

给定单向链表的头指针和一个要删除的节点的值，定义一个函数删除该节点。

返回删除后的链表的头节点。

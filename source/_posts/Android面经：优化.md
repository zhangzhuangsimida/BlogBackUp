---
title: Android面经：优化
date: 2021-07-01 23:54:27
categories:
- Android 
- 面经
tags:
- Android 
- 面经
---


# Android面经：优化
## UI渲染优化
### 内存抖动
内存抖动，所谓内存抖动就是短时间产生大量对象又在短时间内马上释放。
短时间产生大量对象超出阈值，内存不够，同样会触发GC操作。

在onDraw()方法中创建的对象要么赋值给局部变量，要么赋值给成员变量，赋值给局部变量时，onDraw()方法退出后就再也没有其他地方引用到这个对象，下次gc时就会被回收，赋值给成员变量时，下次onDraw()方法内会对该成员变量重新赋值，旧的对象变的没有任何引用，下次gc时会被回收。如果在onDraw()方法中创建的对象被加入一个List类型成员变量中，只有在view被回收时才会被回收，因为每个新创建的对象都被list强引用，可能导致内存溢出。
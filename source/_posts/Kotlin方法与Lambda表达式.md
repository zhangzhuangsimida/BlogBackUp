---
title: Kotlin方法与Lambda表达式
date: 2021-04-25 18:41:00
categories:
- kotlin
tags:
- kotlin
 - 方法
---

# Kotlin方法与Lambda表达式
<!-- more -->

Java中对象是一等公民，而在Kotlin中方法是一等公民。

Java中方法分为成员方法和类方法，Kotlin直接在文件中即可定义方法。

## Kotlin的方法

### 方法声明

<img src="Kotlin方法与Lambda表达式/image-20210425184401937.png" alt="image-20210425184401937" style="zoom: 50%;" />

```kotlin
fun functionLearn(days: Int):Boolean {
    return days > 100
}
```

#### 类方法

- companion object 实现的类方法
- 静态类
- 全局静态

 kotlin中没有静态方法，我们可以借助companion object来实现方法的目的

##### companion object 实现的类方法

```kotlin
class Person {
    companion object {
        fun test2() {
            println("companion object 实现的类方法")
        }
    }
}
Person.test2()
```

##### 静态类

```kotlin
/**
 * 整个静态类
 */
object NumUtil {
    fun double(num: Int): Int {
        return num * 2
    }
}
```

##### 全局静态

我们可以直接新建一个Kotlin file 然后定义一些常方法。

###### 单表达式方法

当方法返回单个表达式时，可以省略花括号并且在 = 富豪之后指定代码即可：

fun double(x: Int): Int = x * 2

```kotlin
fun double(x: Int): Int = x * 2
```

当返回值类型可由编译器推断时，显示声明返回类型是可选的：

```kotlin
fun double(x: Int) = x * 2
```

### 方法参数

- 默认参数
- 具名参数
- 可变数量参数

#### 默认参数

方法参数可以有默认值，当省略相应的参数时使用默认值，与其Java相比，这可以减少重载数量：

```kotlin
fun read(b: Array<Byte>, off: Int = 0, len: Int = b.size) { /*……*/ }
```

我们可以通过类型后面的 = 来设置默认值。

如果一个默认参数在一个五默认值的参数之前，那么该默认值只能通过使用具名参数调用该方法来使用：

```kotlin
fun foo(bar: Int = 0, baz: Int) { /*……*/ }

foo(baz = 1) // 使用默认值 bar = 0
```


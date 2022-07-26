---
title: Gradle详解
date: 2022-01-05 11:02:55
categories:
tags:
---

# Gradle配置文件拆解

<!--more-->

## gradle 是什么

是构建⼯具，不是语⾔

它⽤了 Groovy 这个语⾔，创造了⼀种 DSL，但它本身不是语⾔

## 怎么构建？

按照 gradle 的规则（build.gradle、settings.gradle、gradle-wrapper、gradle 语法）

## 闭包

Java 的 Lambda 表达式：是单抽象⽅法（SAM）的接⼝的匿名类对象的快捷写法，只是⼀个语法糖。

Kotlin 的 Lambda 表达式：和匿名函数相当，实质上是⼀个函数类型的对象，并不只是语法糖。

Groovy 的 Lambda 表达式：Groovy ⾥不叫「Lambda」表达式，⽽是叫「闭包」；在功能上，和 Kotlin 的 Lambda ⽐较相似，都是⼀个「可以传递的代码块」，具体的功能⽐ Kotlin 的 Lambda 更强⼀些，但基本的概念是⼀样的。

## 为什么 Groovy 可以写出类似 JSON 格式的配置？

因为它们其实都是⽅法调⽤，只是⽤闭包来写成了看起来像是 JSON 型的格式。

## buildTypes 和 productFlavors

## compile, implementation 和 api

implementation：不会传递依赖

compile / api：会传递依赖；api 是 compile 的替代品，效果完全等同

当依赖被传递时，⼆级依赖的改动会导致 0 级项⽬重新编译；当依赖不传递时，⼆级依赖的改动不会导致 0 级项⽬重新编译

## task

使⽤⽅法： ./gradlew taskName

task 的结构：

```groovy
task taskName {
初始化代码
doFirst {
task 代码
 }
doLast {
task 代码
 }
}
```

doFirst() doLast() 和普通代码段的区别：

- 普通代码段：在 task 创建过程中就会被执⾏，发⽣在 confifiguration 阶段

- doFirst() 和 doLast()：在 task 执⾏过程中被执⾏，发⽣在 execution 阶段。如果⽤户没有直接或间接执⾏ task，那么它的 doLast() doFirst() 代码不会被执⾏

- doFirst() 和 doLast() 都是 task 代码，其中 doFirst() 是往队列的前⾯插⼊代码，doLast() 是往队列的后⾯插⼊代码
- ask 的依赖：可以使⽤ task taskA(dependsOn: b) 的形式来指定依赖。指定依赖后，task 会在⾃⼰执⾏前先执⾏⾃⼰依赖的 task。

## gradle 执⾏的⽣命周期

三个阶段：

1. 初始化阶段：执⾏ settings.gradle，确定主 project 和⼦ project

2. 定义阶段：执⾏每个 project 的 bulid.gradle，确定出所有 task 所组成的有向⽆环图

3. 执⾏阶段：按照上⼀阶段所确定出的有向⽆环图来执⾏指定的 task

在阶段之间插⼊代码：

⼀⼆阶段之间：

settings.gradle 的最后

⼆三阶段之间：

```groovy
afterEvaluate {

插⼊代码

}
```

# Gradle插件

## 

---
title: Dart语言入门
date: 2021-07-16 15:24:52
categories:
- Flutter
- Dart
tags:
- Flutter
- Dart
---

# Dart 语言入门

## Dart基础知识

- 强类型语言，静态类型
  - Java ，C#等
- 面向对象 OOP
  - Python、C++、object-C、Java、Kotlin、Swift、C#、Ruby与PHP等
- JIT和AOT
  - 即时编译，开发期间、更快编译，更快的重载
  - AOT 事前编译，release期间更快更流畅

DartPad ：在线调试Dart https://dartpad.dev/?null_safety=true

##  常用数据类型

### 数字

- num ：dart数字类型的父类，即接受整型，也能接收浮点型，有两个子类
- int： 整型，num的子类
- double：双精度，num的子类

## 程序入口

Js没有预定义入口函数，Dart中每个app必须有一个顶级入口函数`main()`

```dart
//Dart
main() {
  
}
```

控制台输出

Dart使用`print`输出到控制台：

```dart
//Js
console.log("hello");
//Dart
print('hello ');
```

## 变量

**Dart是类型安全的**- 它使用静态类型检查和运行时的组合，检查以确保变量的值始终与变量的静态值匹配类型，尽管类型是必须的，但是某些类型的注释是可选的，因为Dart会执行类型推断

### 创建和分配变量

Js 无法定义变量类型

Dart，变量必须是明确的类型或者系统能分析的类型

```
//Javascript
var name = "Javascript"
//Dart
String name = 'dart';
```

内置类型

Dart 语言支持下列内容：

- [Numbers](https://dart.cn/guides/language/language-tour#numbers) (`int`, `double`)
- [Strings](https://dart.cn/guides/language/language-tour#strings) (`String`)
- [Booleans](https://dart.cn/guides/language/language-tour#booleans) (`bool`)
- [Lists](https://dart.cn/guides/language/language-tour#lists) (也被称为 *arrays*)
- [Sets](https://dart.cn/guides/language/language-tour#sets) (`Set`)
- [Maps](https://dart.cn/guides/language/language-tour#maps) (`Map`)
- [Runes](https://dart.cn/guides/language/language-tour#characters) (常用于在 `Characters` API 中进行字符替换)
- [Symbols](https://dart.cn/guides/language/language-tour#symbols) (`Symbol`)
- The value `null` (`Null`)

[Dart类型系统](https://dart.cn/guides/language/type-system)

### 默认值

Js未初始化的变量是 `undfined`

Dart未初始化的变量是`null`

> 注意 Dart中数字也被当成对象，所以只要带数字类型的未初始化变量的值都是null

```
//Js
var a = name;  // == undefined
//Dart
var name; // == null
int x // == null
```

## 检查null或0

Js 中，1或任何非null对象都会被视为true

```javascript
//Javascript
var myNull = null;
if(!myNull) {
  console.log("null is treated as false“)；
}
var zero = 0;
if(!zero){
  console.log("0 is treated as false");
}
```

Dart中，只有布尔值为`true`的才被视为true

```dart
var myNull = null;
if(myNull == null) {
	print('use "== null" to check null');
}
var zero = 0;
if(zero == 0) {
  print('use "== 0" to check zero');
}
```

### Dart null检查最佳实践

从Dart 1.12开始，

## Functions



## 异步
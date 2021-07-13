---
title: '后盾JS-8:JS函数'
date: 2021-07-09 08:51:28
categories:
- Javascript
tags:
- Javascript
- 
---

# Javascript

函数是将复用的代码块封装起来的模块，在JS中函数还有其他语言所不具有的特性，接下来我们会详细掌握使用技巧。

## 声明定义

在JS中函数也是对象函数是`Function`类的创建的实例，下面的例子可以方便理解函数是对象。

```javascript
let func = new Function("title", "console.log(title)");
func('后盾人');
```

这里可以str可以直接调用切割函数是因为函数本身就是对象。
```javascript
  let str = new String("hdcms.com");
  console.log(str);
  let start = "houdunren.com";
  console.log(str.substr(0,1));
```

标准语法是使用函数声明来定义函数,`{}`后面不需要跟`；`，但是若是赋值语句则需要加`；`

```javascript
// 标准语法定义，末尾不需要加;
function func(num) {
	return ++num;
}
console.log(hd(3));

//赋值给变量，末尾需要；
let cms = function(title) {
  console.log(title);
};
cms("后盾人");
```



对象字面量属性函数简写

```javascript
let user = {
  name: null,
  getName: function (name) {
    return this.name;
  },
  //简写
  setName (name) {
    this.name = name;
  }
};
user.setName('Joe');
console.log(user.getName())
```

### 全局函数定义

全局函数会声明在window对象中，这不正确建议使用后面章节的模块处理

```javascript
console.log(window.screenX); //2200
```

当我们定义了 `screenX` 函数后就覆盖了window.screenX方法

```javascript
function screenX() {
  return "后盾人";
}
console.log(screenX()); //后盾人
```

使用`let/const`时不会压入window

```javascript
let hd = function() {
  console.log("后盾人");
};
window.hd(); //window.hd is not a function
```

## 匿名函数和函数提升

### 函数提升

数也会提升到前面，优先级行于`var`变量提高

```javascript
console.log(hd()); //后盾人
function hd() {
	return '后盾人';
}
```

变量函数定义不会被提升

```javascript
console.log(hd()); //后盾人

function hd() {
	return '后盾人';
}
var hd = function () {
	return 'hdcms.com';
}
console.log(hd()); //hdcms.com
```

### 匿名函数

函数是对象所以可以通过赋值来指向到函数对象的指针，当然指针也可以传递给其他变量，注意后面要以`;`结束。下面使用函数表达式将 `匿名函数` 赋值给变量

```javascript
let hd = function(num) {
  return ++num;
};

console.log(hd instanceof Object); //true

let cms = hd;
console.log(cms(3));
```

标准声明的函数优先级更高，解析器会优先提取函数并放在代码树顶端，所以标准声明函数位置不限制，所以下面的代码可以正常执行。

```javascript
console.log(hd(3));
function hd(num) {
	return ++num;
};
```

标准声明优先级高于赋值声明

```javascript
console.log(hd(3)); //4

function hd(num) {
  return ++num;
}

var hd = function() {
  return "hd";
};
```

程序中使用匿名函数的情况非常普遍

```javascript
function sum(...args) {
  return args.reduce((a, b) => a + b);//不用写函数名，因为也不会复用
}
console.log(sum(1, 2, 3));
```

## 立即执行和作用域解决冲突

立即执行函数指函数定义时立即执行

- 可以用来定义私有作用域防止污染全局作用域

```javascript
"use strict";
(function () {
    var web = 'houdunren';
})();
console.log(web); //web is not defined
```

使用 `let/const` 有块作用域特性，所以使用以下方式也可以产生私有作用域

```javascript
{
	let web = 'houdunren';
}
console.log(web);
```

### 解决冲突

我们定义两个js文件4.1.js ，4.2.js，这两个文件拥有相同的方法，

4.2.js：

```javascript

function hd () {
  console.log("4.2-hd");
}

function show () {
   console.log("4.2-hshowd");
}
```

在代码中引用

```html
  <script src="4.1.js"></script>
  <script src="4.2.js"></script>
```

直接引用4.1的方法永远无法调用，因为4.1的方法被4.2的同名方法覆盖了

我们可以用立即执行函数产生的私有作用域来解决冲突

```javascript
(function (window) {
  function hd () {
    console.log("4.2-hd");
  }

  function show () {
    console.log("4.2-hshowd");
  }
  window.js2 = { hd, show };
})(window);
```

也可以利用`let/const` 有块作用域的特性，产生私有作用域来解决

```javascript
{
  function hd () {
    console.log("4.2-hd");
  }

  function show () {
    console.log("4.2-hshowd");
  }
  window.js2 = { hd, show };
}
```


---
title: Koa入门
date: 2021-03-07 23:04:57
categories:
- 前端
 - Node
  - Koa
tags:
- 前端
 - Node
  - Koa
---

# Koa 简介

##什么是Koa

Koa是一个新的Web框架，致力于成为web应用和 API 开发领域中的一个更小的、更有表现力的、更健壮的基石。

利用 **asyc 函数** 丢弃回调函数，并增强错误处理。Koa没有任何预置的中间件，可以快速地编写服务端的应用程序。

### 核心概念

- koa application （应用程序）
- Context （上下文） 责任链模式使用中间件响应request
- Request （请求）、Response （响应）

<img src="Koa入门1-简介和原理.assets/image-20210308084411717.png" alt="image-20210308084411717" style="zoom:50%;" />

###Hello Wolrd

```
npm init -y
npm install --save koa
```

index.js

```
const Koa = require('koa')
const app = new Koa()

app.use(async ctx => { 
  ctx.body = 'Helllo World'
})
//端口号 3000
app.listen(3000)
```

运行

```
node index.js
```

## 原理

### Request &Response

ctx对象包括此次请求的host，request ，response等信息。

ctx.request 获取request信息，包括请求方法和内容。

### api url =》function ，router？

npmjs.com 下载koa-router

### ctx，sync
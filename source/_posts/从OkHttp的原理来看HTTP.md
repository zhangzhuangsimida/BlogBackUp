---
title: 从OkHttp的原理来看HTTP
date: 2021-07-27 18:08:58
categories:
- Android
- OkHttp
tags:
- Android
- OkHttp
---

# 从OkHttp的原理来看HTTP

## OkHttp的演进之路

- 原生方案不好用，Square 自己造： OkHttp的初版
- 从头撸到脚：脱离对原生的依赖
- 被Android官方收录: 成为业界公认最佳方案

## OkHttp基本使用方法

1. 创建一个OkHttp的实例

   ```java
    OkHttpClient client = new OkHttpClient.Builder().build();
   ```

2. 创建Request

   ```java
    Request request = new Request.Builder().url("http://hencoder.com").build();
   ```

3. 创建`Call`并发起请求

   ```java
   client.newCall(request).enqueue(new Callback() { 
   	@Override
   	public void onFailure(Call call, IOException e) {}
   	@Override
   	public void onResponse(Call call, Response response) throws IOException {
           Log.d("okhttp response",response.body().string());
   }});
   ```

   


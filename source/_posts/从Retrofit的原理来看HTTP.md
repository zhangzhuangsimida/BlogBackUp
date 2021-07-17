---
title: 从Retrofit的原理来看HTTP
date: 2021-07-14 17:36:46
categories:
- Android
- Retrofit
tags:
- Android
- Retrofit
- Http
---

# 从Retrofit的原理来看HTTP

```java
Retrofit retrofit = new Retrofit.Builder()
    .baseUrl("https://api.github.com/")
  	
    .build();

GitHubService service = retrofit.create(GitHubService.class);
```

3. 调用创建出的Service实例的对应方法，创建出相应的可以用来发起网络请求的 `Call` 对象

```java
Call<List<Repo>> repos = service.listRepos("octocat");
```

4. 使用 Call.execute() 或者 Call.enqueue() 来发起请求

```java
 repos.enqueue(callback);
```

Call.enqueue()方法执行的请求仍然是并行的，为了提升效率是不会排队执行的。 

## Retrofit 源码结构总结


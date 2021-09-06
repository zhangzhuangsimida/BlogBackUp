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

## 基本使用

1. 创建一个interface作为WebService的请求集合，在里面用注解(Annotation)写入需要配置的请求方法

```java
public interface GitHubService { 
  @GET("users/{user}/repos")
	Call<List<Repo>> listRepos(@Path("user") String user);
}
```

2. 在正式代码里用 `Retrofit `创建出 interface 的实例

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

Call.enqueue(),是异步的，方法执行的请求仍然是并行的，为了提升效率是不会排队执行的。 

Call.execute() 是同步的。

##  Retrofit 源码结构总结

1. 通过 Retrofit.create(Class) 方法创建出 Service interface 的实例，从 而使得 Service 中配置的方法变得可用，这是 Retrofit 代码结构的核心;

2. Retrofit.create() 方法内部，使用的是`Proxy.newProxyInstance() `方法来创建 Service 实例。这个方法会为参数中的多个 interface (具体到 Retrofit 来说，是固定传入一个 interface)创建 一个对象，这个对象实现了所有 interface 的每个方法，并且每个方法的实现都 是雷同的:

   调用对象实例内部的一个` InvocationHandler `成员变量的`invoke()`方法，并把自己的方法信息传递进去。这样就在实质上实现了代理 

   逻辑:interface 中的方法全部由一个另外设定的 InvocationHandler 对象 来进行代理操作。并且，这些方法的具体实现是在运行时生成 interface 实例时 才确定的，而不是在编译时(虽然在编译时就已经可以通过代码逻辑推断出来)。这就是网上所说的「动态代理机制」的具体含义。

3. 因此，` invoke() `方法中的逻辑，就是 Retrofit 创建 Service 实例的关键。这 个方法内有三行关键代码，共同组成了具体逻辑: `ServiceMethod` 的创建:

   1.  ```java
   loadServiceMethod(method)
     ```
     
      这行代码负责读取 interface 中原方法的信息(包括返回值类型、方法注解、参数类型、参数注解)，并将这些信息做初步分析。实际返回的是一个`CallAdapted` 。

   2. `OkHttpCall `的创建:

      ```java
      new OkHttpCall<>(requestFactory, args, callFactory, responseConverter)
      ```

   3.  `adapt()`方法:

      ```java
       callAdapter.adapt(call);
      ```

      这个方法会使用一个 CallAdapter 对象来把 OkHttpCall 对象进行转换，生成一个新的对象。默认情况下，返回的是一个 ExecutorCallbackCall ，它的作用是把操 作切回主线程后再交给 Callback 。

## 源码分析：Retrofit.create() 

### loadServiceMethod

```java
  public <T> T create(final Class<T> service) {
    //验证 service 接口
    validateServiceInterface(service);
    // 动态代理创建service实例
    return (T) Proxy.newProxyInstance(service.getClassLoader(), new Class<?>[] { service },
        new InvocationHandler() {
          ... invoke()..
        });
  }
```

#### validateServiceInterface： 验证service 接口

```java
private void validateServiceInterface(Class<?> service) {
  //第一步 校验，service必须是接口不能是一个类
  if (!service.isInterface()) {
    throw new IllegalArgumentException("API declarations must be interfaces.");
  }
	//第二步：校验 接口和接口的父类是否是泛型接口，如果是则会报错
  // 双向队列 check
  Deque<Class<?>> check = new ArrayDeque<>(1); 
  // 向check队列里加入一个service
  check.add(service); 
  while (!check.isEmpty()) {
    //取出刚加入check队列的service，进行处理，当check中的service为空的时候结束校验
    Class<?> candidate = check.removeFirst();
    // 看看service的TypeParameter是否是空，也就是是否包含泛型接口，若包含抛出异常
    if (candidate.getTypeParameters().length != 0) {
      StringBuilder message = new StringBuilder("Type parameters are unsupported on ")
          .append(candidate.getName());
      if (candidate != service) {
        message.append(" which is an interface of ")
            .append(service.getName());
      }
      throw new IllegalArgumentException(message.toString());
    }
    //把这个service继承的接口也加入check队列里面
    Collections.addAll(check, candidate.getInterfaces());
  }
	//第三步：判断是否进行激进验证
  //validateEagerly，是否提前对业务接口中的注解进行验证转换的标志位。
  if (validateEagerly) {
    Platform platform = Platform.get();
    // 对每个方法遍历
    for (Method method : service.getDeclaredMethods()) {
      // 判断是否是默认方法/静态方法，如果是，则不验证
      if (!platform.isDefaultMethod(method) && !Modifier.isStatic(method.getModifiers())) {
        // 将方法加载，这样如果方法有报错就可以提前暴露，
        //但是由于使用了反射，在提前验证模式下会对所有接口使用，消耗性能较多
        loadServiceMethod(method);
      }
    }
  }
}
```

#### 核心：动态代理 Proxy.newProxyInstance

代理：一个类生成的对象实现了接口，那么这个类就是代理这些接口的实现，这个对象就是这个实际的代理。

动态代理：这个代理类是在运行时实现的

```java
/**
* 参数1: service.getClassLoader() 为了生成类的classLoader，不重要，其他classLoader也能替代
* 参数2：new Class<?>[] { service }一个数组，提供给动态代理的service，在retrofit的实现中只有一个元素
* 参数3: 匿名类InvocationHandler，通过它创建service实例，核心是 invoke方法
*/
(T) Proxy.newProxyInstance(service.getClassLoader(), new Class<?>[] { service },
        new InvocationHandler() {
          private final Platform platform = Platform.get();
          private final Object[] emptyArgs = new Object[0];
					
          @Override public @Nullable Object invoke(Object proxy, Method method,
              @Nullable Object[] args) throws Throwable {
            // 如果方法不是接口里的方法，而是object里的方法，就不代理了直接调用
            if (method.getDeclaringClass() == Object.class) {
              return method.invoke(this, args);
            }
            
            // 不代理Java8中的默认方法，就不代理了，直接调用
            if (platform.isDefaultMethod(method)) {
              return platform.invokeDefaultMethod(method, service, proxy, args);
            }
            
            // 返回ServiceMethod 并执行invoke 方法
            return loadServiceMethod(method).invoke(args != null ? args : emptyArgs);
          }
        })
```

#### loadServiceMethod(method)

```java
// 带缓存的加载
ServiceMethod<?> loadServiceMethod(Method method) {
  //从缓存中获取方法  ServiceMethod
    ServiceMethod<?> result = serviceMethodCache.get(method);
  //若result 不为空，直接返回
    if (result != null) return result;
  //若result 为空就是没缓存，那就把它加载出来，再放入缓存（cache)里面，再返回
    synchronized (serviceMethodCache) {
      result = serviceMethodCache.get(method);
      if (result == null) {
        // 加载：核心代码 加载ServiceMethod实例
        result = ServiceMethod.parseAnnotations(this, method);
        serviceMethodCache.put(method, result);
      }
    }
    return result;
  }
```

#### ServiceMethod 

```java
abstract class ServiceMethod<T> {
  static <T> ServiceMethod<T> parseAnnotations(Retrofit retrofit, Method method) {
    
    // 传递 requestFactory ，用于创建 OkHttpCall
    RequestFactory requestFactory = RequestFactory.parseAnnotations(retrofit, method);

    Type returnType = method.getGenericReturnType();
    if (Utils.hasUnresolvableType(returnType)) {
      throw methodError(method,
          "Method return type must not include a type variable or wildcard: %s", returnType);
    }
    if (returnType == void.class) {
      throw methodError(method, "Service methods cannot return void.");
    }
  	//核心 ，通过HttpServiceMethod生成HttpServiceMethod实例
    //HttpServiceMethod是ServiceMethod的子类
    // 最终返回的是HttpServiceMethod 类
    return HttpServiceMethod.parseAnnotations(retrofit, method, requestFactory);
  }
	// 抽象类，动态代理 方法中最终调用的就是这个方法的实例
  abstract @Nullable T invoke(Object[] args);
}
```

#### HttpServiceMethod  核心方法：invoke

包含了OkHttpCall的创建和adapt(适配过程)

```java
abstract class HttpServiceMethod<ResponseT, ReturnT> extends ServiceMethod<ReturnT> {

  static <ResponseT, ReturnT> HttpServiceMethod<ResponseT, ReturnT> parseAnnotations(
      Retrofit retrofit, Method method, RequestFactory requestFactory) {
    ...
     
    if (!isKotlinSuspendFunction) {
      // 若不是Kotlin的挂起方法，则实例化CallAdapted
      return new CallAdapted<>(requestFactory, callFactory, responseConverter, callAdapter);
    } else if (continuationWantsResponse) {
      ...
    } else {
     ...
    }
  }
	//CallAdapter CallAdapted 继承了HttpServiceMethod，实例化返回的就是它
  static final class CallAdapted<ResponseT, ReturnT> extends HttpServiceMethod<ResponseT, ReturnT> {
    
    // CallAdapted类的核心  CallAdapter
    private final CallAdapter<ResponseT, ReturnT> callAdapter;

    CallAdapted(RequestFactory requestFactory, okhttp3.Call.Factory callFactory,
        Converter<ResponseBody, ResponseT> responseConverter,
        CallAdapter<ResponseT, ReturnT> callAdapter) {
      super(requestFactory, callFactory, responseConverter);
      this.callAdapter = callAdapter;
    }
		// adapt 方法的实例化，被invoke调用
    @Override protected ReturnT adapt(Call<ResponseT> call, Object[] args) {
      return callAdapter.adapt(call);
    }
  }
  
  // Retrofi.create 调用的动态代理中，serviceMethod最终调用的就是invoke方法
  // 而LoadServicMethod 中实例化的就是这个类（HttpServiceMethod）的invoke方法
  @Override final @Nullable ReturnT invoke(Object[] args) {
    //实例化  OkHttpCall
    Call<ResponseT> call = new OkHttpCall<>(requestFactory, args, callFactory, responseConverter);
    //调用 adapt 方法（是个抽象方法）
    return adapt(call, args);
  }
	// adapt 抽象方法
  protected abstract @Nullable ReturnT adapt(Call<ResponseT> call, Object[] args);
  ...
}
```

### OkHttpCall

```java
// 发送请求时调用的Call.enqueue() 就是OkHttpCall()实例的enqueue方法
final class OkHttpCall<T> implements Call<T> {
  ...
  @Override public void enqueue(final Callback<T> callback) {
    Objects.requireNonNull(callback, "callback == null");
    okhttp3.Call call;
    Throwable failure;
    
    synchronized (this) {
      if (executed) throw new IllegalStateException("Already executed.");
      executed = true;
      call = rawCall;
      failure = creationFailure;
      if (call == null && failure == null) {
        try {
          //创建 okhttp3.Call call对象
          call = rawCall = createRawCall();
        } catch (Throwable t) {
          throwIfFatal(t);
          failure = creationFailure = t;
        }
      }
    }

    ...
    //执行 okhttp3.call 对象的enqueu方法，发起网络请求
    call.enqueue(new okhttp3.Callback() {
      @Override public void onResponse(okhttp3.Call call, okhttp3.Response rawResponse) {
        Response<T> response;
        try {
          //解析网络请求： okhttp拿到较底层的数据流后解析成response对象
          response = parseResponse(rawResponse);
        } catch (Throwable e) {
          throwIfFatal(e);
          callFailure(e);
          return;
        }

        try {
          // 回调给调用它的 Call
          callback.onResponse(OkHttpCall.this, response);
        } catch (Throwable t) {
          throwIfFatal(t);
          t.printStackTrace(); // TODO this is not great
        }
      }

      @Override public void onFailure(okhttp3.Call call, IOException e) {
        callFailure(e);
      }

      private void callFailure(Throwable e) {
        try {
          callback.onFailure(OkHttpCall.this, e);
        } catch (Throwable t) {
          throwIfFatal(t);
          t.printStackTrace(); // TODO this is not great
        }
      }
    });
  }
    
    
  //实例化 okhttp3.Call，也就是创建请求
  private okhttp3.Call createRawCall() throws IOException {
    okhttp3.Call call = callFactory.newCall(requestFactory.create(args));
    if (call == null) {
      throw new NullPointerException("Call.Factory returned null.");
    }
    return call;
  }
  //解析 response的方法，
  Response<T> parseResponse(okhttp3.Response rawResponse) throws IOException {
    ...  // 创建 okhttp.response 的解析方法
     T body = responseConverter.convert(catchingBody) ....
  }
}
```

#### 创建OkHttpCall的过程

在`OkhttpCall`中，我们调用`createRawCall()`方法创建了`OkhttpCall`，但是它其实是通过`requestFactory`创建的

追根溯源我们会发现 其实在`HttpServiceMethod`中`CallAdapted`创建的过程中传递了requestFactory是,而这个参数是在`ServiceMethod`的`parseAnnotations()`中传递的

RequestFactory  会分析注解中配置等请求方法，是否含有body等配置再记录，分析出完整的拼装方案 。

最终使用RequestFactory .create() 方法创建出一个 okhttp3.Request解析方案

```java
final class RequestFactory {
  ...
 RequestFactory build() {
 okhttp3.Request create(Object[] args) throws IOException {
   private void parseMethodAnnotation(Annotation annotation) {
      if (annotation instanceof DELETE) {
        parseHttpMethodAndPath("DELETE", ((DELETE) annotation).value(), false);
      
        ....
   }       
 }
   //创建 okhttp3.Request 请求
  okhttp3.Request create(Object[] args) throws IOException {...}     
}
```

Response 解析方案是也是在Retrofit的Build方法中调用addConverterFactory方法配置的，Retrofit的Build中维护一个converterFactories，可以在创建Retrofit对象时配置Response解析方案 eg：

```kotlin
 val retrofit = Retrofit.Builder()
            .baseUrl("https://api.github.com/")
            .addConverterFactory(GsonConverterFactory.create()) // 增加Gson 解析方案
            .build()
```

### adapt 适配过程

#### ExecutorCallbackCall

```java
final class DefaultCallAdapterFactory extends CallAdapter.Factory {
  private final @Nullable Executor callbackExecutor;
  ...
  @Override public @Nullable CallAdapter<?, ?> get(
      Type returnType, Annotation[] annotations, Retrofit retrofit) {
    ...
    return new CallAdapter<Object, Call<?>>() {
      @Override public Type responseType() {
        return responseType;
      }
		//所以执行adapt方法，返回的是被 ExecutorCallbackCall包裹的 okhttpcall
      @Override public Call<Object> adapt(Call<Object> call) {
        return executor == null
            ? call
            : new ExecutorCallbackCall<>(executor, call);
      }
    };
  }
  
  static final class ExecutorCallbackCall<T> implements Call<T> {
    final Executor callbackExecutor;
    final Call<T> delegate;
    // invoke   中调用的，delegate 就是okhttpcall
   ExecutorCallbackCall(Executor callbackExecutor, Call<T> delegate) {
      this.callbackExecutor = callbackExecutor;
      this.delegate = delegate;
    }      
    // call back 参数是 Mainactvity中 call.enqueue 中传递的参数  
    @Override public void enqueue(final Callback<T> callback) {
      Objects.requireNonNull(callback, "callback == null");
			// 切到主线程，回调网络请求Response
      delegate.enqueue(new Callback<T>() {
        @Override public void onResponse(Call<T> call, final Response<T> response) {
          callbackExecutor.execute(() -> {
            if (delegate.isCanceled()) {
              callback.onFailure(ExecutorCallbackCall.this, new IOException("Canceled"));
            } else {
              callback.onResponse(ExecutorCallbackCall.this, response);
            }
          });
        }

        @Override public void onFailure(Call<T> call, final Throwable t) {
          callbackExecutor.execute(() -> callback.onFailure(ExecutorCallbackCall.this, t));
        }
      });
    }  
}  
```



我们知道，在`loadServiceMethod()`中返回的实例是`CallAdapted`，一个继承了`HttpServicemethod`的实例，

`adapt`方法调用的`callAdapter`类，来自`callFactory`，追根溯源，我们发现`callFactory`的初始化来自`Retrofit Builder`中的参数，由`Platform（平台管理类`）配置，默认情况使用`DefaultCallAdapterFactory`是一个`Executor` 

```java
  public static final class Builder {
    private final Platform platform;
    //CallAdapterFactory配置类
    private @Nullable okhttp3.Call.Factory callFactory;
    private @Nullable HttpUrl baseUrl;
    // converterFactories 配置类
    private final List<Converter.Factory> converterFactories = new ArrayList<>();
    private final List<CallAdapter.Factory> callAdapterFactories = new ArrayList<>();

    Builder(Platform platform) {
      this.platform = platform;
    }

    public Builder() {
      this(Platform.get());
    }

    Builder(Retrofit retrofit) {
      platform = Platform.get();
      callFactory = retrofit.callFactory;
      baseUrl = retrofit.baseUrl;

      // 如果没有配置converterFactories，则会使用默认的
      for (int i = 1,
          size = retrofit.converterFactories.size() - platform.defaultConverterFactoriesSize();
          i < size; i++) {
        converterFactories.add(retrofit.converterFactories.get(i));
      }

      // 若没有配置CallAdapterFactory，会使用默认的
      for (int i = 0,
          size = retrofit.callAdapterFactories.size() - platform.defaultCallAdapterFactoriesSize();
          i < size; i++) {
        callAdapterFactories.add(retrofit.callAdapterFactories.get(i));
      }

      callbackExecutor = retrofit.callbackExecutor;
      validateEagerly = retrofit.validateEagerly;
    }
```

#### 增加RxJava的支持

给作为WebService的接口集合增加RxJava操作方法

```kotlin
 interface GitHubService : Serializable {
    ...
    @GET("users/{user}/repos")
    fun listReposRx(@Path("user") user: String?): Single<List<Repo>>
}
```

调用时，让Retrofit开启RxJava支持

```kotlin
val retrofit = Retrofit.Builder()
            .baseUrl("https://api.github.com/")
            .addCallAdapterFactory(RxJava2CallAdapterFactory.create())// 增加RxJavaA支持
            .addConverterFactory(GsonConverterFactory.create()) // 增加Gson 解析
            .build()
val service: GitHubService = retrofit.create(GitHubService::class.java)
val reposRx = service.listReposRx("octocat")
reposRx.subscribe()
```

在Retrofit 调用build方法的时候，`RxCallAdapterFactories`会先于`DefaultCallAdapterFactory`加入到`CallAdapterFactories`队列之中

在Http调用`createCallAdapter()`创建`Calladapter`时会调用`Retrofit`的`nextCallAdapter()`方法，然后遍历

`callAdapterFactories`根据所需的参数返回adapter，因为我们增加了`RxCallAdapterFactories`，当出现RxJava相关的参数时候会返回对应的 RxJava2CallAdapter

RxJava2CallAdapterFactory:

```java
private RxJava2CallAdapterFactory(@Nullable Scheduler scheduler, boolean isAsync) {
  this.scheduler = scheduler;
  this.isAsync = isAsync;
}
// 返回支持RxJava的calladapter
@Override public @Nullable CallAdapter<?, ?> get(
    Type returnType, Annotation[] annotations, Retrofit retrofit) {
  Class<?> rawType = getRawType(returnType);

  if (rawType == Completable.class) {
    // Completable is not parameterized (which is what the rest of this method deals with) so it
    // can only be created with a single configuration.
    return new RxJava2CallAdapter(Void.class, scheduler, isAsync, false, true, false, false,
        false, true);
  }

  boolean isFlowable = rawType == Flowable.class;
  boolean isSingle = rawType == Single.class;
  boolean isMaybe = rawType == Maybe.class;
  if (rawType != Observable.class && !isFlowable && !isSingle && !isMaybe) {
    return null;
  }

  boolean isResult = false;
  boolean isBody = false;
  Type responseType;
  if (!(returnType instanceof ParameterizedType)) {
    String name = isFlowable ? "Flowable"
        : isSingle ? "Single"
        : isMaybe ? "Maybe" : "Observable";
    throw new IllegalStateException(name + " return type must be parameterized"
        + " as " + name + "<Foo> or " + name + "<? extends Foo>");
  }

  Type observableType = getParameterUpperBound(0, (ParameterizedType) returnType);
  Class<?> rawObservableType = getRawType(observableType);
  if (rawObservableType == Response.class) {
    if (!(observableType instanceof ParameterizedType)) {
      throw new IllegalStateException("Response must be parameterized"
          + " as Response<Foo> or Response<? extends Foo>");
    }
    responseType = getParameterUpperBound(0, (ParameterizedType) observableType);
  } else if (rawObservableType == Result.class) {
    if (!(observableType instanceof ParameterizedType)) {
      throw new IllegalStateException("Result must be parameterized"
          + " as Result<Foo> or Result<? extends Foo>");
    }
    responseType = getParameterUpperBound(0, (ParameterizedType) observableType);
    isResult = true;
  } else {
    responseType = observableType;
    isBody = true;
  }

  return new RxJava2CallAdapter(responseType, scheduler, isAsync, isResult, isBody, isFlowable,
      isSingle, isMaybe, false);
}
```


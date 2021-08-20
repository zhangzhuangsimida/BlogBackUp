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

   

## OkHttp 框架结构分析

发出请求的大框架：`client.newCall(request).enqueue(new Callback(){...})`

1. 先是newCall 里面创建一个RealCall，创建完之后执行的enqueue方法也就是RealCall的enqueue方法
2. RealCall的enqueue调用了Dispatcher的enqueue方法，将最新的call扔进readyAsyncCalls里（将准备好要执行还没执行的List）
3. 符合条件的call全部执行一遍：将符合条件的call放进 executableCalls，遍历执行每个asyncCall的executeOn方法
4. executeOn本质上执行runnable的run方法，到了run里面会调用getResponseWithInterceptorChain()获得响应，最终获得响应就会给responseCallback返回结果，出错就会返回responseCallback的onFailure()
5. 同步执行execute一般不会使用，但是例如拿到token之后再请求一次就需要用到同步请求，它会直接调用getResponseWithInterceptorChain()方法发起请求获得响应

`enqueue`方法，是一个抽象接口调用的：

```kotlin
interface Call : Cloneable {...fun enqueue(responseCallback: Callback)...}
```

`newCall` 方法是`HttpClient`中的方法,会返回一个`RealCall`对象，他`Call`接口的实现。

```kotlin
/** Prepares the [request] to be executed at some point in the future. */
override fun newCall(request: Request): Call = RealCall(this, request, forWebSocket = false)
```

RealCall：

```kotlin
class RealCall(
  //OkHttpClient：Okhttp的大总管，所有的通用配置都在这配置比如超时时间等
  val client: OkHttpClient,
  //初始的请求，后续会多次封装，对于Okhttp来说request就是你发起一个Http请求需要的所有条件（method，body，header等）
  val originalRequest: Request,
  // WebSocket：应用层协议，服务器可以主动给客户端发送消息，适用于频繁刷新数据，链接是通过HTTP协议建立的（为了兼容浏览器）
  val forWebSocket: Boolean
) : Call {...}
  ...
  
  override fun enqueue(responseCallback: Callback) {
    synchronized(this) {
      check(!executed) { "Already Executed" }
      executed = true
    }
    //跟踪错误，监听请求内容
    callStart()
    //调用dispatcher执行enqueue
    client.dispatcher.enqueue(AsyncCall(responseCallback))
  }
  
   private fun callStart() {
    // 跟踪出现的错误用于错误分析
    this.callStackTrace=Platform.get().getStackTraceForCloseable("response.body().close()")
   // 反馈/回调，evetnListener是Http交互过程的监听器，他会监听各种内容【header，body开始发送/接收，TCP    的链接（socket）等】，对整个程序没有干预。
    eventListener.callStart(this)
  }
  ...
  internal inner class AsyncCall(
    private val responseCallback: Callback
  ) : Runnable {
    ...
    }
    ..
	
    fun executeOn(executorService: ExecutorService) {
      client.dispatcher.assertThreadDoesntHoldLock()

      var success = false
      try {
        // 切换线程执行 runnable方法
        executorService.execute(this)
        success = true
      } catch (e: RejectedExecutionException) {
        ...
      } finally {
        ...
      }
    }

    override fun run() {
      threadName("OkHttp ${redactedUrl()}") {
        var signalledCallback = false
        timeout.enter()
        try {
          //拿到服务器的响应
          val response = getResponseWithInterceptorChain()
          signalledCallback = true
          //responseCallback就是在真正使用时调用的Callback：client.newCall(request).enqueue(new Callback(){...})
          responseCallback.onResponse(this@RealCall, response)
        } catch (e: IOException) {
          if (signalledCallback) {
          ...
          } else {
            responseCallback.onFailure(this@RealCall, e)
          }
        } catch (t: Throwable) {
          ...
        } finally {
          ...
        }
      }
    }
  }

  
}  
```

Dispatcher

```kotlin
class Dispatcher constructor() {
  //依靠Excutor进行线程调度，若没有线程调度同时有多个请求发生时只能排队
  private var executorServiceOrNull: ExecutorService? = null
  // maxRequests： 最大有多少个请求同时进行，超出需要等待。可以配置
  @get:Synchronized var maxRequests = 64
    set(maxRequests) {
      require(maxRequests >= 1) { "max < 1: $maxRequests" }
      synchronized(this) {
        field = maxRequests
      }
      promoteAndExecute()
    }
	
  //maxRequestsPerHost你的每个主机同时能有多少个请求，超出需要等待。可以配置
  @get:Synchronized var maxRequestsPerHost = 5
    set(maxRequestsPerHost) {
      require(maxRequestsPerHost >= 1) { "max < 1: $maxRequestsPerHost" }
      synchronized(this) {
        field = maxRequestsPerHost
      }
      promoteAndExecute()
    }
  // 双向队列，存放准备好执行还没执行的请求
  //这种请求有两种，
  //1. 调用enqueue传递的call: AsyncCall
  //2. 刚才传递来的call：AsynCall，因为稍后的请求个数被限制了被挡住的请求。
  private val readyAsyncCalls = ArrayDeque<AsyncCall>()
 
  internal fun enqueue(call: AsyncCall) {
    synchronized(this) {
      readyAsyncCalls.add(call)
      if (!call.call.forWebSocket) {
        // 和主机的连接数是根据主机名存储的变量，存在每个AsyncCall内部且可以共享
        // 遍历已有的AsyncCall，如果有和这次请求的Host建立的链接就拿出来
        val existingCall = findExistingCallWithHost(call.host)
        if (existingCall != null) call.reuseCallsPerHostFrom(existingCall)
      }
    }
    // 执行readyAsyncCalls里的请求
    promoteAndExecute()
  }

	// promote:推举 Execute：执行，把符合条件（还没执行过且执行它不会超负载）的没有执行的Call全部推举出来拿去执行。
  private fun promoteAndExecute(): Boolean {
    this.assertThreadDoesntHoldLock()
		
    val executableCalls = mutableListOf<AsyncCall>()
    val isRunning: Boolean
    synchronized(this) {
      //遍历已经准备好的Call
      val i = readyAsyncCalls.iterator()
      while (i.hasNext()) {
        val asyncCall = i.next()
				//把符合条件的筛选出来（不超过maxRequests和maxRequestsPerHost最大限制）
        if (runningAsyncCalls.size >= this.maxRequests) break // Max capacity.
        if (asyncCall.callsPerHost.get() >= this.maxRequestsPerHost) continue // Host max capacity.

        i.remove()
        asyncCall.callsPerHost.incrementAndGet()
        //将筛选过的Call推举出来，即加入专门的Listzhong（executableCalls）
        executableCalls.add(asyncCall)
        //顺便加入正在执行的Calls，用于做记录
        runningAsyncCalls.add(asyncCall)
      }
      isRunning = runningCallsCount() > 0
    }
		//将推举出的asyncCall挨个去执行，遍历执行AsyncCall的ExecuteOn函数
    for (i in 0 until executableCalls.size) {
      val asyncCall = executableCalls[i]
      asyncCall.executeOn(executorService)
    }

    return isRunning
  }
  
   fun executeOn(executorService: ExecutorService) {
      client.dispatcher.assertThreadDoesntHoldLock()
       ...
        //切换线程，将Runnable丢过去执行
        executorService.execute(this)
       ...
    }  
}  
```

`execute`方法同步执行,一般来说请求网络都是要异步的，但也有例外比如：请求过程中拿到一个token要继续请求，我们不需要切换线程。

RealCall: 直接调用getResponseWithInterceptorChain

```kotlin
 override fun execute(): Response {
    synchronized(this) {
      check(!executed) { "Already Executed" }
      executed = true
    }
    timeout.enter()
    callStart()
    try {
      client.dispatcher.executed(this)
      return getResponseWithInterceptorChain()
    } finally {
      client.dispatcher.finished(this)
    }
  }
```

### OkHttpClient 配置清单

```kotlin
open class OkHttpClient internal constructor(
  builder: Builder
) : Cloneable, Call.Factory, WebSocket.Factory {
	//调度器，用于调度后台发起的网络请求， 有后台总请求数和单主机总请求数的控制。
  @get:JvmName("dispatcher") val dispatcher: Dispatcher = builder.dispatcher
  //连接池：管理连接的工具，存储批量的连接，创建一个连接的时候不先创建，先看连接池里有没有，有就直接调用
  //若调用结束也不急着销毁，先存储在连接池，超时不用再销毁（看配置）
  //池概念：同类变量的管理，通过资源复用和动态回收形成性能和资源占用的动态平衡。
  //连接池重用 
  //http1：已经用完了的连接可以在创建其他连接时重用
  //http2：正在使用的连接也可以重用（多路复用）
  @get:JvmName("connectionPool") val connectionPool: ConnectionPool = builder.connectionPool
  //拦截器
  @get:JvmName("interceptors") val interceptors: List<Interceptor> =
      builder.interceptors.toImmutableList()
  //请求拦截器
  @get:JvmName("networkInterceptors") val networkInterceptors: List<Interceptor> =
      builder.networkInterceptors.toImmutableList()
  //生产eventListener 的工厂，是监听各种事件的监听器（请求发起，连接创立等）
  @get:JvmName("eventListenerFactory") val eventListenerFactory: EventListener.Factory =
      builder.eventListenerFactory
  //连接失败/请求失败是否重试的配置，403不算失败，管理的是TCP请求连接失败或者无响应，默认true
  @get:JvmName("retryOnConnectionFailure") val retryOnConnectionFailure: Boolean =
      builder.retryOnConnectionFailure
	//自动重新认证。配置之后，在 请求收到 401 状态码的响应时，会直接调用authenticator，手动加入Authorization header 之后自动重新发起请求
  @get:JvmName("authenticator") val authenticator: Authenticator = builder.authenticator
	//重定向时，如果原先请求的是 http 而重定向的目标是 https，或者原先请求的是 https 而重定向的目标是 //http，是否依然自动 follow。(记得，不是「是否自动 follow HTTPS URL 重定向的意思，而是是否自动 follow //在 HTTP 和 HTTPS 之间切换的重定向)
  @get:JvmName("followRedirects") val followRedirects: Boolean = builder.followRedirects
	//额外开关默认true：上面开关打开的前提下，重定向的时候发生协议切换的时候是否进行重定向，有人可以利用协议切换进行恶意攻击
  @get:JvmName("followSslRedirects") val followSslRedirects: Boolean = builder.followSslRedirects
  //饼干罐cookie：饼干Jar：罐子，存储是默认不实现的。想用要自己实现
  @get:JvmName("cookieJar") val cookieJar: CookieJar = builder.cookieJar
  //缓存，本地缓存
  @get:JvmName("cache") val cache: Cache? = builder.cache
	//域名解析成ip地址，使用的Java原生方法
  @get:JvmName("dns") val dns: Dns = builder.dns
  //代理，为了做网络管制，请求都要由代理服务器选择性转发可以代理 DIRECT(直连),HTTP,SOCKS，默认null
  @get:JvmName("proxy") val proxy: Proxy? = builder.proxy
  //proxySelector的select方法会返回一个List<Proxy>，若proxy没配置，则会在连接后调用select()遍历
  //List<Proxy> 选择可以使用的Proxy（默认直连）
  @get:JvmName("proxySelector") val proxySelector: ProxySelector =
      when {
        builder.proxy != null -> NullProxySelector
        else -> builder.proxySelector ?: ProxySelector.getDefault() ?: NullProxySelector
      }
	// Proxy独立的验证机制
  @get:JvmName("proxyAuthenticator") val proxyAuthenticator: Authenticator =
      builder.proxyAuthenticator
	//Http的请求本质是个Socket，使用socketFactory创建
  @get:JvmName("socketFactory") val socketFactory: SocketFactory = builder.socketFactory
	
  private val sslSocketFactoryOrNull: SSLSocketFactory?
  // socket TCP连接开始之前 
  @get:JvmName("sslSocketFactory") val sslSocketFactory: SSLSocketFactory
    get() = sslSocketFactoryOrNull ?: throw IllegalStateException("CLEARTEXT-only client")
	// 证书的验证器，（x509是证书格式标准，是系统提供的类）
  @get:JvmName("x509TrustManager") val x509TrustManager: X509TrustManager?
  //连接标准，应用层支持的 Socket 设置，即使用明文传输(用于 HTTP)还是某个版本的 TLS(用于 HTTPS)。
  @get:JvmName("connectionSpecs") val connectionSpecs: List<ConnectionSpec> =
      builder.connectionSpecs
	//支持的应用层协议，即 HTTP/1.1、 HTTP/2 等。
  // SPDY_3（http2前身，已经废弃）
  // H2_PRIOR_KNOWLEDGE 没有TLS的HTTP2
  // 浏览器是无法确定是否支持HTTP2，一般会加一个Upgrade： h2c的header试着请求，询问服务器是否支持
  //Http2.0，但是Android客户端不需要这样试探
  @get:JvmName("protocols") val protocols: List<Protocol> = builder.protocols
  // --------证书验证相关--------------
  // 验证证书的Host是否是自己请求的
  @get:JvmName("hostnameVerifier") val hostnameVerifier: HostnameVerifier = builder.hostnameVerifier
  //用于设置 HTTPS 握手 过程中针对某个 Host 额外的的 Certificate Public Key Pinner，即把网站证 书链
  //中的每一个证书公钥直接拿来提前配置进 OkHttpClient 里去，作为正常的证书验证机制之外的一次额外验证。
  //最好不要使用，因为若是换了签发机构，但是客户端的信息还是写的老证书的信息，可能造成问题
  @get:JvmName("certificatePinner") val certificatePinner: CertificatePinner
	// x509TrustManager的操作员，验证证书是否合法
  @get:JvmName("certificateChainCleaner") val certificateChainCleaner: CertificateChainCleaner?
  // --------证书验证相关--------------
  @get:JvmName("callTimeoutMillis") val callTimeoutMillis: Int = builder.callTimeout
  //建立连接(TCP 或 TLS)的超时时间。
  @get:JvmName("connectTimeoutMillis") val connectTimeoutMillis: Int = builder.connectTimeout

  //发起请求到读到响应数据的超时时间。
  @get:JvmName("readTimeoutMillis") val readTimeoutMillis: Int = builder.readTimeout
  //发起请求并被目标服务器接受的超时时间。(为什么?因为有时候对方服务器可能由于某种原因而不读取你的 Request)
  @get:JvmName("writeTimeoutMillis") val writeTimeoutMillis: Int = builder.writeTimeout
  //心跳机制
  @get:JvmName("pingIntervalMillis") val pingIntervalMillis: Int = builder.pingInterval
}
```

OkHttpClient 相当于配置中心，所有的请求都会共享这些配置(例如出错

是否重试、共享的连接池)。 OkHttpClient 中的配置主要有

Dns：Java 自带的方法，从域名获得ip地址

```kotlin
interface Dns {
  @Throws(UnknownHostException::class)
  fun lookup(hostname: String): List<InetAddress>
  companion object {
    
    @JvmField
    val SYSTEM: Dns = DnsSystem()
    private class DnsSystem : Dns {
      override fun lookup(hostname: String): List<InetAddress> {
        try {
          return InetAddress.getAllByName(hostname).toList()
        } catch (e: NullPointerException) {
          throw UnknownHostException("Broken system behaviour for dns lookup of $hostname").apply {
            initCause(e)
          }
        }
      }
    }
  }
}
```

### 核心方法getResponseWithInterceptorChain()

RealCall

```kotlin
@Throws(IOException::class)
  internal fun getResponseWithInterceptorChain(): Response {
    //第一部分 把一个个的Interceptor加入List中，网络事件拦截器（雁过插毛器）
    // 
    val interceptors = mutableListOf<Interceptor>()
    interceptors += client.interceptors
    interceptors += RetryAndFollowUpInterceptor(client)
    interceptors += BridgeInterceptor(client.cookieJar)
    interceptors += CacheInterceptor(client.cache)
    interceptors += ConnectInterceptor
    if (!forWebSocket) {
      interceptors += client.networkInterceptors
    }
    interceptors += CallServerInterceptor(forWebSocket)
	//第二部分： 创建一个 RealInterceptorChain实例（拦截器的链），核心仍然是Interceptor的List，不过封装
  //了一些功能
    val chain = RealInterceptorChain(
        call = this,
        interceptors = interceptors,
        index = 0,
        exchange = null,
        request = originalRequest,
        connectTimeoutMillis = client.connectTimeoutMillis,
        readTimeoutMillis = client.readTimeoutMillis,
        writeTimeoutMillis = client.writeTimeoutMillis
    )
	// 第三部分： 调用这个拦截器链
    var calledNoMoreExchanges = false
    try {
      //拦截器链处理初始request
      val response = chain.proceed(originalRequest)
      if (isCanceled()) {
        response.closeQuietly()
        throw IOException("Canceled")
      }
      return response
    } catch (e: IOException) {
      calledNoMoreExchanges = true
      throw noMoreExchanges(e) as Throwable
    } finally {
      if (!calledNoMoreExchanges) {
        noMoreExchanges(null)
      }
    }
  }

```

链式调用模型：

拦截器依次调用过去，再调用回来，每个拦截器都有前置/中间/后置工作，除了最后一环。

![image-20210812172830889](从OkHttp的原理来看HTTP/image-20210812172830889.png)

RealInterceptorChain:

```kotlin
  @Throws(IOException::class) //proceed 继续
  override fun proceed(request: Request): Response {
    check(index < interceptors.size)

    calls++

    if (exchange != null) {
      check(exchange.finder.sameHostAndPort(request.url)) {
        "network interceptor ${interceptors[index - 1]} must retain the same host and port"
      }
      check(calls == 1) {
        "network interceptor ${interceptors[index - 1]} must call proceed() exactly once"
      }
    }

    // 获取第index个 interceptor
    val next = copy(index = index + 1, request = request)
    val interceptor = interceptors[index]

    @Suppress("USELESS_ELVIS")
    //执行 interceptor的拦截方法 注意，interceptor是个接口，我们接下来拿默认的实例
    //RetryAndFollowUpInterceptor举例
    val response = interceptor.intercept(next) ?: throw NullPointerException(
        "interceptor $interceptor returned null")

    if (exchange != null) {
      check(index + 1 >= interceptors.size || next.calls == 1) {
        "network interceptor $interceptor must call proceed() exactly once"
      }
    }

    check(response.body != null) { "interceptor $interceptor returned a response with no body" }

    return response
  }
```

RetryAndFollowUpInterceptor：

```kotlin
// 重试，重定向，拦截器
class RetryAndFollowUpInterceptor(private val client: OkHttpClient) : Interceptor {

  @Throws(IOException::class)
  override fun intercept(chain: Interceptor.Chain): Response {
    // 前置工作
    val realChain = chain as RealInterceptorChain
    var request = chain.request
    val call = realChain.call
    var followUpCount = 0
    var priorResponse: Response? = null
    var newExchangeFinder = true
    //始终执行请求，直到不需要重试或者重定向
    while (true) {
      call.enterNetworkInterceptorExchange(request, newExchangeFinder)

      var response: Response
      var closeActiveExchange = true
      try {
        if (call.isCanceled()) {
          throw IOException("Canceled")
        }

        try {
          // 中间工作：交给下一棒
          response = realChain.proceed(request)
          // 后置工作：拿到下一棒返回的response再进行
          newExchangeFinder = true
          // 出错时的请求
        } catch (e: RouteException) {
          // 通过某条连接线路连接失败了
          // 是否可以重试如果不能，直接抛异常
          if (!recover(e.lastConnectException, call, request, requestSendStarted = false)) {
            throw e.firstConnectException
          }
          newExchangeFinder = false
          //继续请求
          continue
        } catch (e: IOException) {
          // An attempt to communicate with a server failed. The request may have been sent.
          if (!recover(e, call, request, requestSendStarted = e !is ConnectionShutdownException)) {
            throw e
          }
          newExchangeFinder = false
          continue
        }

        // Attach the prior response if it exists. Such responses never have a body.
        if (priorResponse != null) {
          response = response.newBuilder()
              .priorResponse(priorResponse.newBuilder()
                  .body(null)
                  .build())
              .build()
        }

        val exchange = call.interceptorScopedExchange
        val followUp = followUpRequest(response, exchange)

        if (followUp == null) {
          if (exchange != null && exchange.isDuplex) {
            call.timeoutEarlyExit()
          }
          closeActiveExchange = false
          return response
        }

        val followUpBody = followUp.body
        if (followUpBody != null && followUpBody.isOneShot()) {
          closeActiveExchange = false
          return response
        }

        response.body?.closeQuietly()

        if (++followUpCount > MAX_FOLLOW_UPS) {
          throw ProtocolException("Too many follow-up requests: $followUpCount")
        }

        request = followUp
        priorResponse = response
      } finally {
        call.exitNetworkInterceptorExchange(closeActiveExchange)
      }
    }
  }
  // recover 恢复连接
  private fun recover(
    e: IOException,
    call: RealCall,
    userRequest: Request,
    requestSendStarted: Boolean
  ): Boolean {
    // okhttpclient配置是否需要重试
    if (!client.retryOnConnectionFailure) return false
    // 判断是否可以恢复连接
    if (requestSendStarted && requestIsOneShot(e, userRequest)) return false
    if (!isRecoverable(e, requestSendStarted)) return false
    ...
  }
    private fun isRecoverable(e: IOException, requestSendStarted: Boolean): Boolean {
    // 判断是否可以恢复连接
    if (e is ProtocolException) {
      return false
    }
    
    if (e is InterruptedIOException) {
    ...
  }

}  
```



## 总结

- `OkHttpClient `相当于配置中心，所有的请求都会共享这些配置(例如出错是否重试、共享的连接池)。 

- `newCall(Request) `方法会返回一个 RealCall 对象，它是 Call 接口的它是 Call 接口的实现。当调用 `RealCall.execute()` 的时候，` RealCall.getResponseWithInterceptorChain() `会被调用，它会发起网络请求并拿到返回的响应，装进一个` Response `对象并作为返回值返 回; 

  `RealCall.enqueue() `被调用的时候大同小异，区别在于`enqueue()` 会使用` Dispatcher `的线程池来把请求放在后台线程进行，但实质上使用的同样也是 `getResponseWithInterceptorChain() `方法。

- `getResponseWithInterceptorChain()` 方法做的事:把所有配置好的 `Interceptor `放在一个 List 里，然后作为参数，创建一个` RealInterceptorChain `对象，并调用` chain.proceed(request) `来发起请求和获取响应。
- 在 `RealInterceptorChain` 中，多个` Interceptor` 会依次调用自己的`intercept()` 方法。这个方法会做三件事:
  1. 对请求进行预处理
  2. 预处理之后，重新调用 `RealIntercepterChain.proceed() `把请求交给下一个 `Interceptor`
  3. 在下一个 `Interceptor `处理完成并返回之后，拿到 Response 进行后续处理

> 当然了，最后一个 Interceptor 的任务只有一个:做真正的网络请求并 拿到响应

- 从上到下，每级 Interceptor 做的事:
  - 首先是开发者使用` addInterceptor(Interceptor) `所设置的，它们会按照开发者的要求，在所有其他 `Interceptor` 处理之前，进行最早的 预处理工作，以及在收到 Response 之后，做最后的善后工作。如果你有统 一的 header 要添加，可以在这里设置;
  - 然后是` RetryAndFollowUpInterceptor` :它会对连接做一些初始化工作，并且负责在请求失败时的重试，以及重定向的自动后续请求。它的存在，可以让重试和重定向对于开发者是无感知的;
  - `BridgeInterceptor` :它负责一些不影响开发者开发，但影响 HTTP 交互的一些额外预处理。例如，`Content-Length` 的计算和添加、`gzip` 的支持` (Accept-Encoding: gzip)`、`gzip` 压缩数据的解包，都是发生在这里;
  - `CacheInterceptor `:它负责 Cache 的处理。把它放在后面的网络交互相关` Interceptor `的前面的好处是，如果本地有了可用的 Cache，一个 请求可以在没有发生实质网络交互的情况下就返回缓存结果，而完全不需要 开发者做出任何的额外工作，让 Cache 更加无感知;
  - `ConnectInterceptor` :它负责建立连接。在这里，OkHttp 会创建出网 络请求所需要的 TCP 连接(如果是 HTTP)，或者是建立在 TCP 连接之上 的 TLS 连接(如果是 HTTPS)，并且会创建出对应的 `HttpCodec `对象 (用于编码解码 HTTP 请求);
  - 然后是开发者使用 `addNetworkInterceptor(Interceptor)` 所设置 的，它们的行为逻辑和使用 `addInterceptor(Interceptor)` 创建的 一样，但由于位置不同，所以这里创建的` Interceptor `会看到每个请求和响应的数据(包括重定向以及重试的一些中间请求和响应)，并且看到的 是完整原始数据，而不是没有加` Content-Length` 的请求数据，或者` Body` 还没有被 gzip 解压的响应数据。多数情况，这个方法不需要被使用，不过 如果你要做网络调试，可以用它;
  - `CallServerInterceptor` :它负责实质的请求与响应的 I/O 操作，即 往 Socket 里写入请求数据，和从 Socket 里读取响应数据。


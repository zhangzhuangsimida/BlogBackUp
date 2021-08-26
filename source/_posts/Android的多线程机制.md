---
title: Android的多线程机制
date: 2021-08-25 12:10:57
categories:
- Android
- 线程
tags:
- Android
- 线程
---

# Android的多线程机制

## Android Handler 机制模型

本质: 在某个指定的运行中的线程上执行代码

思路: 在接受任务的线程上执行循环判断

### 基本实现:

- Thread 里 while 循环检查
- 加上 Looper(优势在于自定义 Thread 的代码可以少写很多，,把要处理的任务放入消息队列Messages（一个链表）中)
- 再加上 Handler进行任务的处理(优势在于功能分拆，而且可以有多个 Handler，hander收到的Message包含int型，runnable【callback】，object)

模型：

```java
public class CustomThread extends Thread {
    Looper looper = new Looper();

    @Override
    public void run() {
        looper.loop();

    }

    class Looper {
        private Runnable task;
        private AtomicBoolean quit = new AtomicBoolean(false);

        synchronized void setTask(Runnable task) {
            this.task = task;
        }

        void quit() {
            quit.set(true);
        }

        void loop() {
            // 无限循环的线程
            while (!quit.get()) {
                synchronized (this) {
                    if (task != null) {
                        task.run();
                        task = null;
                    }
                }

            }
        }
    }
```



##  Android Handler 机制:



### ThreadLocal:

每个线程不共享的内存

Eg:

```java
final ThreadLocal<Integer> threadNumber = new ThreadLocal<>();

new Thread() {
  @Override
  public void run() {
    threadNumber.set(1);
    threadNumber.get();
  }
}.start();
new Thread() {
  @Override
  public void run() {
    threadNumber.set(2);
    threadNumber.get();
  }
}.start();
```

Android中调用Looper.myLooper() 获取线程持有的Looper对象，会发现它是存储在ThreadLocal中的

Looper:

```java
static final ThreadLocal<Looper> sThreadLocal = new ThreadLocal<Looper>();
 
public static @Nullable Looper myLooper() {
        return sThreadLocal.get();
    }
```

### HandlerThread:

具体的线程 

HandlerThread

```java
public class HandlerThread extends Thread {
   ...
   // 启动Looper
    @Override
    public void run() {
        mTid = Process.myTid();
        Looper.prepare();
        synchronized (this) {
            mLooper = Looper.myLooper();
            notifyAll();
        }
        Process.setThreadPriority(mPriority);
       //初始化Looper
        onLooperPrepared();
       // Looper 开启循环
        Looper.loop();
        mTid = -1;
    }
    
   ...
   
}
```



### Looper:

负责循环、条件判断和任务执行 

Looper:

```kotlin
public final class Looper {
    static final ThreadLocal<Looper> sThreadLocal = new ThreadLocal<Looper>();
  
    public static void prepare() {
        prepare(true);
    }
		// 初始化，存储当前创建的Looper到ThreadLocal
    private static void prepare(boolean quitAllowed) {
        if (sThreadLocal.get() != null) {
            throw new RuntimeException("Only one Looper may be created per thread");
        }
        sThreadLocal.set(new Looper(quitAllowed));
    }
  	// 开启Loop循环
 		public static void loop() {
       
        ...
				// 死循环
        for (;;) {
          // 一直拿下一个Message
            Message msg = queue.next(); // might block
            ... 
          //处理Message
            try {
              // target是一个Handler ，每个message需要一个Handler来处理
                msg.target.dispatchMessage(msg);
                if (observer != null) {
                    observer.messageDispatched(token, msg);
                }
                dispatchEnd = needEndTime ? SystemClock.uptimeMillis() : 0;
            } catch (Exception exception) {
                if (observer != null) {
                    observer.dispatchingThrewException(token, msg, exception);
                }
                throw exception;
            } finally {
                ThreadLocalWorkSource.restore(origWorkSource);
                if (traceTag != 0) {
                    Trace.traceEnd(traceTag);
                }
            }
            if (logSlowDelivery) {
                if (slowDeliveryDetected) {
                    if ((dispatchStart - msg.when) <= 10) {
                        Slog.w(TAG, "Drained");
                        slowDeliveryDetected = false;
                    }
                } else {
                    if (showSlowLog(slowDeliveryThresholdMs, msg.when, dispatchStart, "delivery",
                            msg)) {
                        // Once we write a slow delivery log, suppress until the queue drains.
                        slowDeliveryDetected = true;
                    }
                }
            }
            if (logSlowDispatch) {
                showSlowLog(slowDispatchThresholdMs, dispatchStart, dispatchEnd, "dispatch", msg);
            }

            if (logging != null) {
                logging.println("<<<<< Finished to " + msg.target + " " + msg.callback);
            }

            // Make sure that during the course of dispatching the
            // identity of the thread wasn't corrupted.
            final long newIdent = Binder.clearCallingIdentity();
            if (ident != newIdent) {
                Log.wtf(TAG, "Thread identity changed from 0x"
                        + Long.toHexString(ident) + " to 0x"
                        + Long.toHexString(newIdent) + " while dispatching to "
                        + msg.target.getClass().getName() + " "
                        + msg.callback + " what=" + msg.what);
            }

            msg.recycleUnchecked();
        }
    }  
}
```



### Handler:

负责任务的定制和线程间传递，本质

```java
public class Handler {
  ...
  // 下发msg
    public void dispatchMessage(@NonNull Message msg) {
     // callback = runnable
        if (msg.callback != null) {
          // 执行runnable
            handleCallback(msg);
        } else {
          
            if (mCallback != null) {
                if (mCallback.handleMessage(msg)) {
                    return;
                }
            }
          // 如果没有callback（runnable）要自己处理message
          // 外界调用它就要自己重写handleMessage 自己定义处理规则
            handleMessage(msg);
        }
    }
  ...
}  
```

创建制定线程/多个Handler

```java
        HandlerThread hanlerThread = new HandlerThread("second");
        Handler handler = new Handler(Looper.getMainLooper());
        Handler handlerSecond = new Handler(hanlerThread.getLooper());
```

### 小结

本质是在某个运行中的线程执行指定的代码，Java只能在没有运行的线程中执行代码。

Java的目标是将任务放入后台，Android的线程机制可以指定线程。

Java要是想做到像Android一样循环过程中执行任务，也需要像Android一样不停的循环，再插入任务，不然无法在已运行的线程添加代码。因为线程间的通信只是协同通信，内存/资源共享，线程直接是无法真正对话的。



## AsyncTask: 的内存泄露



众所周知的原因:AsyncTask 持有外部 Activity 的引用 (官方提示asynctask若不是静态的会持有外部的activity引用导致内存泄漏)

没提到的原因:执行中的线程不会被系统回收

Java 回收策略:没有被 GC Root 直接或间接持有引用的对象，会被回收

所以:

AsyncTask 的内存泄露，其他类型的线程方案(Thread、 Executor、HandlerThread)一样都有，所以不要忽略它们，或者认为 AsyncTask 比别的方案更危险。并没有。

就算是使用 AsyncTask，只要任务的时间不⻓(例如 10 秒之 内)，那就完全没必要做防止内存泄露的处理。

被废弃的原因是因为不好用

### 什么是内存泄漏

内存中的某个对象已经没用处了但是依然无法被回收。

### GC Root:

什么是GC Root：

1. 运行中的线程
2. 静态对象
3. 来自 native code 中的引用

## Service 和 IntentService

Service:后台任务的活动空间（并不会自动切到后台，并不是后台线程）。适用场景:音乐播放器等。

IntentService: 执行单个任务后自动关闭的 Service，既是后台线程工具，又是service工具·

## **Executor**、AsyncTask**、**HandlerThead、**IntentService** 的选择

原则:哪个简单用哪个

- 能用 Executor 就用 Executor
- 需要用到「后台线程推送任务到 UI 线程」时，再考虑 AsyncTask 或者 Handler 
- HandlerThread 的使用场景:原本它设计的使用场景是「在已经运行的指定线 程上执行代码」，但现实开发中，除了主线程之外，几乎没有这种需求，因为 HandlerThread 和 Executor 相比在实际应用中并没什么优势，反而用起来会麻 烦一点。不过，这二者喜欢用谁就用谁吧。
   IntentService:首先，它是一个 Service;另外，它在处理线程本身，没有比 Executor 有任何优势

## 关于 Executor 和 HandlerThread 的关闭

如果在界面组件里创建 Executor 或者 HandlerThread，记得要在关闭的时候(例如 `Activity.onDestroy() `)关闭 Executor 和 HandlerThread。

```java
@Override
protected void onDestroy() { 
	super.onDestroy(); 
	executor.shutdown();
}
```

```java
 @Override
protected void onDestroy() {
	super.onDestroy();
	handlerThread.quit(); // 这个其实就是停止 Looper 的循环
}
```


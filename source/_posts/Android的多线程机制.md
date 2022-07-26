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

## Android 中开启线程的方法

1. HandlerThread,适用于主线程需要和工作线程通信,适用于持续性任务,比如轮训的场景，所有任务串行执行

   缺点:不会像普通线程一样主动销毁资源，会一直运行着，所以可能会造成内存泄漏

2. IntentService,适用于我们的任务需要跨页面读取任务执行的进度，结果。比如后台上传图片，批量操作数据库等。任务执行完成功后，就会自我结束，所以不需要手动stopservice,这是他跟service的区分

## AndroidHandler 机制模型

本质: 在某个指定的运行中的线程上执行代码

思路: 在接受任务的线程上执行循环判断



### 基本实现:

- Thread 里 while 循环检查
- 加上 Looper(优势在于自定义 Thread 的代码可以少写很多，,把要处理的任务放入消息队列Messages（一个链表）中)
- 再加上 Handler进行消息的发送和处理(优势在于功能分拆，而且可以有多个 Handler，hander收到的Message包含int型，runnable【callback】，object)

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

### Handler & Looper & MessageQueue三角关系简述

- 一个线程至多一个looper；一个looper有一个MessageQueue；一个MessageQueue对应多个message；一个MessageQueue对多个Handler。

- **Handler** 进行消息的发送和处理，消息并不是立刻就会处理的，发送的所有消息都会通过enqueueMessage存入消息队列
- MessageQueue 消息队列（单向链表）存储消息，因为同一时间只有一个消息能被处理，所以消息按照被触发的时间存储在队列中，队列头部的消息被触发的时间是最接近的
- **Looper**中有一个Loop方法会遍历整个队列，开启无限的循环检查是否有满足条件的消息，如果有就把消息拿出来分发执行。

- **Message** ：

  - when：被执行的时间戳
  - next： 指向下一个消息的引用关系，形成单向链表
  - target： 代表这个消息是由哪个handler对象发送的，消费的时候也就由哪个Handler消费
  - callback： 消息在消费的时候存在消息优先级的概念，使用handler.post (runnable）会回调给Message的callback，这个callback实质上就是我们传递的callback对象

  消息类型有**同步、异步、同步屏障**消息。

  ![image-20211018234124434](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20211018234124434.png)

```kotlin
    //1. 直接在Runnable中处理任务
    handler.post (runnable= Runnable{
      
    })

    //2.使用Handler.Callback 来接收处理消息
    // 如果传递了callback，消息会优先给callback处理，ActivityThread中有使用过
    val handler =object :Handler(Callback {
        return@Callback true
      
       }
    )
      
    //3. 使用handlerMessage接收处理消息
    val handler =object :Handler(){
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
        }
    }
    val message = Message.obtain()
    handler.sendMessage(message)
```

- **为什么主线程中创建Handler没有绑定looper，也能发送消息呢???**
  - 在ActivityThread.main()方法中调用了Looper.prepareMainLooper()方法创建了主线程的looper, 然后调用了loop()开启消息队列轮训。
  - 通常我们认为ActivityThread就是主线程，事实上它并不是一个线程，而是主线程操作的管理者。

```java
public Handler() {this(null, false);}
public Handler(boolean async) { this(null, async); }
public Handler(Callback callback, boolean async) {
        //如果没调用Looper.prepare则为空
        //主线程创建Handler不用创建Looper，就是ActivityThread在进程入口帮我们调用了Looper.prepareMainLooper()，之后我们创建的handler在这里就可以在这里跟当前线程的Looper进行绑定。
        
        //问题是Looper.myLooper()怎么保证获取到的是本线程的looper对象？    
        mLooper = Looper.myLooper();
        mQueue = mLooper.mQueue;
        mCallback = callback;
        mAsynchronous = async;
    }

```

```java
class Looper{
  // sThreadLocal 是static的变量，可以先简单理解它相当于map，key是线程，value是Looper，
    //那么你只要用当前的线程的sThreadLocal获取当前线程所属的Looper。
   static final ThreadLocal<Looper> sThreadLocal = new ThreadLocal<Looper>();
    //Looper 所属的线程的消息队列
   final MessageQueue mQueue;
  
   private static void prepare(boolean quitAllowed) {
         //一个线程只能有一个Looper，prepare不能重复调用。
        if (sThreadLocal.get() != null) {
            throw new RuntimeException("Only one Looper may be created per thread");
        }
        sThreadLocal.set(new Looper(quitAllowed));
    }
  
  private Looper(boolean quitAllowed) {
        mQueue = new MessageQueue(quitAllowed);
    }
  
  public static @Nullable Looper myLooper() {
        //具体看ThreadLocal类的源码的get方法，
        //简单理解相当于map.get(Thread.currentThread()) 获取当前线程的Looper
        return sThreadLocal.get();
    }
}
```

- **如何让子线程拥有消息分发的能力？?**

  像ActivityThread一样，在入口给他创建looper。

  若是在子线程中开启了Looper和循环，

  势必要显性的调用它的Looper.quitSafely()方法，否则他就会一直循环下去，这个线程就不会被销毁和回收

  ```java
  class HandlerThread extends Thread{
    private  Handler handler
     @overried
     public void run(){
         Looper.prepare()
         //面试题：如何在子线程中弹出toast  Toast.show()
         // Toast在显示之前，还没有添加到窗口上，我们对它的操作就不会触发线程的检查
         //Toast.show() 
            
         createHandler()
     		 // 开启消息的线程的循环，这个消息就会被执行到
         Looper.loop()
     }
    
     private void createHandler(){
       // 在主线程中拿到这个handler，这个代码和HandlerThread类似
      
       handler  = new Handler(){
          @overried
          public void handleMessage(Message msg){
              //处理主线程发送过来的消息
          }
       }
     }
  }
  
  ```

### 消息入队

消息插入MessageQueue的过程

插入队列有两种形式：post和send，无论哪种形式最后都会以Message插入队列

![image-20211019081446543](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20211019081446543.png)

- 获取消息体——享元设计模式（对象共用的模式）

  使用链表的形式复用Message，它的插入删除速度比ArrayList 快的多

```java
class Handler{
  // 对于post方法，都会通过getPostMessage() 把Runnable包装成Message对象
   public final boolean post(@NonNull Runnable r) {
       return  sendMessageDelayed(getPostMessage(r), 0);
   }
   private static Message getPostMessage(Runnable r) {
        Message m = Message.obtain();
        m.callback = r;
        return m;
   }  
}

class Message{
    public static final Object sPoolSync = new Object();
  
    private static Message sPool;
    private static int sPoolSize = 0;   
    // 消息复用池，最多缓存50个对象
    private static final int MAX_POOL_SIZE = 50;
    // Messag.obtain() 拥有对Message对象的共享能力
    // 通过new Message()创建消息对象会造成内存占用过高，频繁GC的问题，推荐使用 Message.obtain()
    // obtain() 获取的Message对象是可以从复用池里进行复用的，而不是每次都创建一个新的对象
    public static Message obtain() {
        //单向链表形式的对象池
        synchronized (sPoolSync) {
            if (sPool != null) {
                Message m = sPool;
                sPool = m.next;
                m.next = null;
                m.flags = 0; 
                sPoolSize--;
                return m;
            }
        }
        return new Message();
    }
  // Message.recycleUnchecked() 提供对象回收的能力
  // Message的对象复用池还是一个对头复用的对象池
  // 当每一条消息被分发/执行完之后 都会执行，从而对Message对象进行重置，清空数据，再插入到链表的头节点里面去 
  // 扩展手势相关的MotionEvent也会提供一个对象复用的对象池
  void recycleUnchecked() {
        flags = FLAG_IN_USE;
        what = 0;
        arg1 = 0;
        arg2 = 0;
        obj = null;
        replyTo = null;
        sendingUid = UID_NONE;
        workSourceUid = UID_NONE;
        when = 0;
        target = null;
        callback = null;
        data = null;

        synchronized (sPoolSync) {
            if (sPoolSize < MAX_POOL_SIZE) {
                next = sPool;
                sPool = this;
                sPoolSize++;
            }
        }
    }
}

```

#### MessageQueue单向链表数据结构模型

- **基本结构：单向链表**，Message的next指向下一个Message节点，从而把一个个Message对象串联起来形成一个链表

- **为什么不使用LinkedList**？因为LinkedList是一个双向链表，每一个节点都会指向前后两个节点的对象，单向链表没必要使用

- **消息入列的方法**
  - 无论使用post还是send 最终都会调用enqueueMessage() 将消息插入到队列里面去
  - 可以使用postSyncBarrier() 发送屏障消息
  - 新消息插入队列中会从队列中找到触发时间（when）小于它的元素，把它插入到后面

![image-20211019085032005](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20211019085032005.png)

**enqueueMessage**

```
class Handler{
  private boolean enqueueMessage(@NonNull MessageQueue queue, Message msg,long uptimeMillis) {
        // 把handler标记给message，不然它不知道谁来处理
        msg.target = this;
        ...
        return queue.enqueueMessage(msg, uptimeMillis);
    }
}

class MessageQueue{
  boolean enqueueMessage(Message msg, long when) {
        //普通消息的target字段不能为空，否则不知道该交由谁来处理这条消息
        if (msg.target == null) {
            throw new IllegalArgumentException("Message must have a target.");
        }
 
        synchronized (this) {
          
            msg.when = when;
            //mMessages始终是队头消息
            Message p = mMessages;
            boolean needWake;
            //如果队头消息为空，或消息的when=0不需要延迟,或newMsg.when<headMsg.when        
            //则插入队头
            if (p == null || when == 0 || when < p.when) {
                // New head, wake up the event queue if blocked.
                msg.next = p;
                mMessages = msg;
                //如果当前Looper处于休眠状态，则本次插入消息之后需要唤醒
                needWake = mBlocked;
            } else {
                
                //要不要唤醒Looper= 当前Looper处于休眠状态 & 队头消息是同步屏障消息 & 新消息是异步消息
                //目的是为了让异步消息尽早执行
                needWake = mBlocked && p.target == null && msg.isAsynchronous();
                Message prev;
                for (;;) {
                    prev = p;
                    p = p.next;
                    //按时间顺序 找到该消息 合适的位置
                    // >>msg1.when=2-->msg.when=4-->msg.when-->6
                    //>>msg1.when=2-->msg.when=4-->【newMsg.when=5】-->msg.when=6   
                    if (p == null || when < p.when) {
                        break;
                    }
                    if (needWake && p.isAsynchronous()) {
                        needWake = false;
                    }
                }
                //跳转链表中节点的指向关系
                msg.next = p; // invariant: p == prev.next
                prev.next = msg;
            }
            //唤醒looper
            if (needWake) {
                nativeWake(mPtr);
            }
        }
        return true;
    }
}

```



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

使用HandlerThread

```java
HandlerThread thread = new HandlerThread("concurrent-thread");
thread.start();
ThreadHandler handler = new ThreadHandler(thread.getLooper()) {
    @Override
    public void handleMessage(@NonNull Message msg) {
              switch (msg.what) {
                  case MSG_WHAT_FLAG_1:
                      break;
              }
          }
      };
handler.sendEmptyMessage(MSG_WHAT_FLAG_1);
thread.quitSafely();

//定义成静态,防止内存泄漏
static class ThreadHandler extends Handler{
public ThreadHandler(Looper looper){
  super(looper)
 }
}

```

HandlerThread源码模型

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

负责任务的定制和线程间传递消息

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

## Handler面试8问

- 为什么主线程不会因为 `Looper.loop()` 里的死循环卡死？

  > 主线程确实是通过 `Looper.loop()` 进入了循环状态，因为这样主线程才不会像我们一般创建的线程一样，当可执行代码执行完后，线程生命周期就终止了。
  >
  > 在主线程的 MessageQueue 没有消息时，便阻塞在 `MessageQueue.next()` 中的 `nativePollOnce()` 方法里，此时主线程会释放 CPU 资源进入休眠状态，直到新消息达到。所以主线程大多数时候都是处于休眠状态，并不会消耗大量 CPU 资源。
  >
  > 这里采用的 linux的epoll 机制，是一种 IO 多路复用机制，可以同时监控多个文件描述符，当某个文件描述符就绪（读或写就绪），则立刻通知相应程序进行读或写操作拿到最新的消息，进而唤醒等待的线程。

- `post` 和 `sendMessage` 两类发送消息的方法有什么区别？

  > `post` 一类的方法发送的是 Runnable 对象，但是其最后还是会被封装成 Message 对象，将 Runnable 对象赋值给 Message 对象中的 callback 变量，然后交由 `sendMessageAtTime()` 方法发送出去。在处理消息时，会在 `dispatchMessage()` 方法里首先被 `handleCallback(msg)` 方法执行，实际上就是执行 Message 对象里面的 Runnable 对象的 `run` 方法。
  >
  > 而 `sendMessage` 一类的方法发送的直接是 Message 对象，处理消息时，在 `dispatchMessage` 里优先级会低于 `handleCallback(msg)` 方法，是通过自己重写的 `handleMessage(msg)` 方法执行。

- 为什么要通过 `Message.obtain()` 方法获取 Message 对象？

  > `obtain` 方法可以从全局消息池中得到一个空的 Message 对象，这样可以有效节省系统资源。同时，通过各种 obtain 重载方法还可以得到一些 Message 的拷贝，或对 Message 对象进行一些初始化。

- Handler 实现发送延迟消息的原理是什么？

  > 我们常用 `postDelayed()` 与 `sendMessageDelayed()` 来发送延迟消息，其实最终都是将延迟时间转为确定时间，然后通过 `sendMessageAtTime()` -> `enqueueMessage` -> `queue.enqueueMessage` 这一系列方法将消息插入到 MessageQueue 中。所以并不是先延迟再发送消息，而是直接发送消息，再借助MessageQueue 的设计来实现消息的延迟处理。
  >
  > 消息延迟处理的原理涉及 MessageQueue 的两个静态方法 `MessageQueue.next()` 和 `MessageQueue.enqueueMessage()`。通过 Native 方法阻塞线程一定时间，等到消息的执行时间到后再取出消息执行。

- 同步屏障 SyncBarrier 是什么？有什么作用？

  > 在一般情况下，同步和异步消息处理起来没有什么不同。只有在设置了同步屏障后才会有差异。同步屏障从代码层面上看是一个 Message 对象，但是其 target 属性为 null，用以区分普通消息。在 `MessageQueue.next()` 中如果当前消息是一个同步屏障，则跳过后面所有的同步消息，找到第一个异步消息来处理。但是开发者调用不了。在ViewRootImpl的UI测绘流程有体现

- IdleHandler 是什么？有什么作用？

  > 当消息队列没有消息时调用或者如果队列中仍有待处理的消息，但都未到执行时间时，也会调用此方法。用以监听主线程空闲状态。

- 为什么非静态类的 Handler 导致内存泄漏？如何解决？

  > 首先，非静态的内部类、匿名内部类、局部内部类都会隐式的持有其外部类的引用。也就是说在 Activity 中创建的 Handler 会因此持有 Activity 的引用。
  >
  > 当我们在主线程使用 Handler 的时候，Handler 会默认绑定这个线程的 Looper 对象，并关联其 MessageQueue，Handler 发出的所有消息都会加入到这个 MessageQueue 中。Looper 对象的生命周期贯穿整个主线程的生命周期，所以当 Looper 对象中的 MessageQueue 里还有未处理完的 Message 时，因为每个 Message 都持有 Handler 的引用，所以 Handler 无法被回收，自然其持有引用的外部类 Activity 也无法回收，造成泄漏。
  >
  > ##### 使用静态内部类 + 弱引用的方式

- 如何让在子线程中弹出toast

  > 调用`Looper.prepare`以及`Looper.loop()`,但是切记线程任务执行完，需要手动调用`Looper.quitSafely()`否则线程不会结束。

## 小结

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

自定义View到测试

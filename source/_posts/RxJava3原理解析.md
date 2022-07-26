---
title: RxJava3原理解析
date: 2021-08-26 16:40:47
categories:
- Android
- RxJava3
tags:
- Android
- RxJava3
---

# RxJava 3 的原理完全解析

## 基本用法

```kotlin
 
@GET("users/{username}/repos")
// Observable和Flow都过重，网络请求 推荐single
fun getRepos(@Path("username") username: String): Single<List<Repo>>
...
api.getRepos("rengwuxian")
 .subscribeOn(Schedulers.io())//请求切换到io线程
 .observeOn(AndroidSchedulers.mainThread())// 回调在主线程
  .subscribe(object : SingleObserver<MutableList<Repo>> {
    override fun onSuccess(repos: MutableList<Repo>) {
       textView.text = "Result :${repos!![0].name}"
  }

  override fun onSubscribe(d: Disposable?) {
   // 订阅产生之后就会回调（网络请求之前）所以适合初始化
   // dispose 丢弃，一般使用时会通知上游停止生产
   textView.text = "正在请求"
   disposeable = d
  }

  override fun onError(e: Throwable) {
     textView.text = e.message ?: e.javaClass.name
  }
})
```

## 框架结构

RxJava 的整体结构是一条链，其中:

1. 链的最上游:生产者 Observable
2. 链的最下游:观察者 Observer
3. 链的中间:各个中介节点，既是下游的 Observable，又是上游的 Observer

## 创建：

Single 为例:

```kotlin
 val single = Single.just("1")
 single.subscribe(object : SingleObserver<String?> {
 override fun onSuccess(t: String?) {
       textView.text = t
  }
        ...
 })
...
```

```kotlin
public abstract class Single<@NonNull T> implements SingleSource<T> { 
 	
  public static <@NonNull T> Single<T> just(T item) {
       ...
       // 钩子函数，重点在于传入了SingleJust实例
        return RxJavaPlugins.onAssembly(new SingleJust<>(item));
    }
  
  public final void subscribe(@NonNull SingleObserver<? super T> observer) {
       
				// 钩子函数，
        observer = RxJavaPlugins.onSubscribe(this, observer);

       ...
        try {
            // 重点方法
            subscribeActual(observer);
        } ...
    }
} 
```
SingleJust:

```kotlin
public final class SingleJust<T> extends Single<T> {

    final T value;

    public SingleJust(T value) {
        this.value = value;
    }

    @Override
    protected void subscribeActual(SingleObserver<? super T> observer) {
      // Disposable.disposed 表示已经被丢弃
      // singlejust是立刻执行后取消的任务，所以可以直接取消
        observer.onSubscribe(Disposable.disposed());
      // 成功，将内部存储的对象传过去也就是Single.just("1")中传的1
        observer.onSuccess(value);
      // 没有onError 因为它是不可能失败的，把一个准备好的对象传过去是不会失败的
    }

}
```

![image-20210826174653269](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210826174653269.png)

## 操作符 Operator(map() 等等):

1. 基于原 Observable 创建一个新的 Observable
2. Observable 内部创建一个 Observer
3. 通过定制 Observable 的 subscribeActual() 方法和 Observer 的 onSuccess() 方法，来实现自己的中介⻆色(例如数据转换、线程切换)

![image-20210826174752970](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210826174752970.png)

Eg:

```kotlin
private fun operatorRx() {
    val single:Single<Int> = Single.just(1)
    val singleString = single.map(object :Function<Int,String>{
        override fun apply(t: Int?): String {
            return  t.toString()
        }
    } )
}
```

Single.map方法：基于原 Observable 创建一个新的 Observable

```kotlin
@CheckReturnValue
@NonNull
@SchedulerSupport(SchedulerSupport.NONE)
public final <@NonNull R> Single<R> map(@NonNull Function<? super T, ? extends R> mapper) {
    Objects.requireNonNull(mapper, "mapper is null");
    //基于原 Observable 创建一个新的 Observable：创建一个SingleMap，将自己身和需要转换的操作符(map)
    //传过去
    return RxJavaPlugins.onAssembly(new SingleMap<>(this, mapper));
}
```

SingleMap：Observable 内部创建一个 Observer

```kotlin
public final class SingleMap<T, R> extends Single<R> {
    final SingleSource<? extends T> source;

    final Function<? super T, ? extends R> mapper;

    public SingleMap(SingleSource<? extends T> source, Function<? super T, ? extends R> mapper) {
        this.source = source;
        this.mapper = mapper;
    }

    @Override
    protected void subscribeActual(final SingleObserver<? super R> t) {
      // 真正执行的代码，将会创建一个MapSingleObserver
        source.subscribe(new MapSingleObserver<T, R>(t, mapper));
    }

    static final class MapSingleObserver<T, R> implements SingleObserver<T> {

        final SingleObserver<? super R> t;

        final Function<? super T, ? extends R> mapper;

        MapSingleObserver(SingleObserver<? super R> t, Function<? super T, ? extends R> mapper) {
            this.t = t;
            this.mapper = mapper;
        }

        @Override
        public void onSubscribe(Disposable d) {
            t.onSubscribe(d);
        }

        @Override
        public void onSuccess(T value) {
            R v;
            try {
              // 若需要转换则使用传来的操作符接口进行转换
                v = Objects.requireNonNull(mapper.apply(value), "The mapper function returned a null value.");
            } catch (Throwable e) {
                Exceptions.throwIfFatal(e);
                onError(e);
                return;
            }
						//转换成功后传递给下游（最表面的观察者，也是开发者真正调用的那个接口回调）
            t.onSuccess(v);
        }

        @Override
        ...
    }
}
```

若再增加操作符也是一样的，只不过会增加更多的被观察者，观察者

![image-20210827153255139](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210827153255139.png)

## Disposable:

上游停止生产，上下游切断联系

 可以通过 dispose() 方法来让上游或内部调度器(或两者都有)停止工作，达到「丢弃」的效果。

>  SingleJust，没有延迟没有后续，可以直接取消

> 总结：Disposable是一个桥接器，dispose时，先看这个生产者（被观察者）有没有来自上游的后续任务，有没有自己生产的后续任务（延时任务）停止工作。

### 有延迟的任务如何取消

```kotlin
 // 延迟调用， ，每间隔一秒调用一次
 Observable.interval(0,1,TimeUnit.SECONDS)
  .observeOn(AndroidSchedulers.mainThread())// 延迟发生在子线程，所以回调到主线程主线程
  .subscribe(object: Observer<Long?> {
    override fun onComplete() {}
    override fun onSubscribe(d: Disposable?) { }
    override fun onNext(t: Long?) {
      textView.text = t.toString()
    }
    override fun onError(e: Throwable?) {}} )
```

```kotlin
public final class ObservableInterval extends Observable<Long> {
    final Scheduler scheduler;
    final long initialDelay;
    final long period;
    final TimeUnit unit;
    ...

    @Override
    public void subscribeActual(Observer<? super Long> observer) {
       //核心方法 实例化 IntervalObserver(下游的observer)
        IntervalObserver is = new IntervalObserver(observer);
        ...
      	if (sch instanceof TrampolineScheduler) {
           ...
        } else {
            // 在后台处理轮训任务，每次执行完毕都会调用  IntervalObserver（is）的run方法
            Disposable d = sch.schedulePeriodicallyDirect(is, initialDelay, period, unit);
            is.setResource(d);
        }
    } 
  ...
  // 没有继承Observer ,继承了一个可取消的disposable
  // 调用dispose方法时，会调用真正的dispose实现
  // 之所以如此复杂，是因为它既要保持链性结构，又要轮训后执行的run方法和dispose指向同一对象统一管理
      static final class IntervalObserver 
      extends AtomicReference<Disposable>
      implements Disposable, Runnable {
        ...
        public void dispose() {
            DisposableHelper.dispose(this);
        }
        // 每次轮训回调都会调用一下run方法
        @Override
        public void run() {
            if (get() != DisposableHelper.DISPOSED) {
                downstream.onNext(count++);
            }
        }
        // 设置内部的dispose
        public void setResource(Disposable d) {
            DisposableHelper.setOnce(this, d);
        }
       ...
    }
}
```

 DisposableHelper

```kotlin
    // 调用内部的disposeable的值
    public static boolean dispose(AtomicReference<Disposable> field) {
        Disposable current = field.get();
        Disposable d = DISPOSED;
      // 拿到内部的Disposable，若没有被取消，则执行Disposable的dispose方法
        if (current != d) {
            current = field.getAndSet(d);
            if (current != d) {
                if (current != null) {
                    current.dispose();
                }
                return true;
            }
        }
        return false;
    }
		// 只设置一次disposable对象
    public static boolean setOnce(AtomicReference<Disposable> field, Disposable d) {
        Objects.requireNonNull(d, "d is null");
      //dispose对象为空的时候才设置
        if (!field.compareAndSet(null, d)) {
            d.dispose();
            if (field.get() != DISPOSED) {
                reportDisposableSet();
            }
            return false;
        }
        return true;
    }
```

### 有上游的任务该如何取消

若是没有延迟和后续的single.map：上游dispose对象会直接传递到下一级，取消任务和它无关

若事件是有延迟无后续Singledelay

```kotlin
  Single.just(1)
           .delay(1,TimeUnit.SECONDS)
           .subscribe(object: SingleObserver<Int?>{
               override fun onSuccess(t: Int?) {
               }...})
```

```kotlin
public final class SingleDelay<T> extends Single<T> {

    final SingleSource<? extends T> source;
    final long time;
    final TimeUnit unit;
    final Scheduler scheduler;
    final boolean delayError;

    public SingleDelay(SingleSource<? extends T> source, long time, TimeUnit unit, Scheduler scheduler, boolean delayError) {
        this.source = source;
        this.time = time;
        this.unit = unit;
        this.scheduler = scheduler;
        this.delayError = delayError;
    }

    @Override
    protected void subscribeActual(final SingleObserver<? super T> observer) {
				//自己的disposeable 实例
        final SequentialDisposable sd = new SequentialDisposable();
        observer.onSubscribe(sd);
       // 不能直接传递上游的disposable，若dipose消息发出时，消息还在上游，上游直接拿到disposable对象，本层终止程序没有问题
      // 若消息已经传到本层级，那么停止消息就应该自己处理（上游singlejust已经没有处理的必要，本层却有延迟功能，这层应该关闭自己的定时器）
        source.subscribe(new Delay(sd, observer));
    }

    final class Delay implements SingleObserver<T> {
        private final SequentialDisposable sd;
        final SingleObserver<? super T> downstream;

        Delay(SequentialDisposable sd, SingleObserver<? super T> observer) {
            this.sd = sd;
            this.downstream = observer;
        }

        @Override
        public void onSubscribe(Disposable d) {
           //收到上游消息之前，若收到取消任务的通知，直接替换上游的disposable
           //本地的disposable被赋值成上游的，即可通知上游终止任务
            sd.replace(d);
        }
  			//若已经收到上游的消息，无论成功失败都需要自己处理
        @Override
        public void onSuccess(final T value) {
         		// disposable替换成线程调度器，若通知取消任务要自主调用线程调度器关闭延时
            sd.replace(scheduler.scheduleDirect(new OnSuccess(value), time, unit));
        }

        @Override
        public void onError(final Throwable e) {
          // disposable替换成线程调度器，若通知取消任务要自主调用线程调度器关闭延时
            sd.replace(scheduler.scheduleDirect(new OnError(e), delayError ? time : 0, unit));
        }

        final class OnSuccess implements Runnable {
           ...
        }

       ...
    }
}
```

```kotlin
//交给内部的Disposable解决
public final class SequentialDisposable
extends AtomicReference<Disposable>
implements Disposable { ...
    public SequentialDisposable(Disposable initial) {
        lazySet(initial);
    }
    ...
    public boolean replace(Disposable next) {
        return DisposableHelper.replace(this, next);
    }

    @Override
    public void dispose() {
        DisposableHelper.dispose(this);
    } ...
}
```

### 有后续无延迟的任务如何取消

ObservableMap的任务取消

dispose也是拿到上游的disposable进行取消，几乎等同于直接拿到上游的对象进行取消
map只是通过包装在消息传达时多做一些操作符操作而已

```kotlin
public final class ObservableMap<T, U> extends AbstractObservableWithUpstream<T, U> {
    final Function<? super T, ? extends U> function;

    public ObservableMap(ObservableSource<T> source, Function<? super T, ? extends U> function) {
        super(source);
        this.function = function;
    }

    @Override
    public void subscribeActual(Observer<? super U> t) {
        source.subscribe(new MapObserver<T, U>(t, function));
    }

    static final class MapObserver<T, U> extends BasicFuseableObserver<T, U> {
        final Function<? super T, ? extends U> mapper;

        MapObserver(Observer<? super U> actual, Function<? super T, ? extends U> mapper) {
            super(actual);
            this.mapper = mapper;
        }

        @Override
        public void onNext(T t) {
            if (done) {
                return;
            }
				...
    }
}
```

```kotlin
public abstract class BasicFuseableObserver<T, R> implements Observer<T>, QueueDisposable<R> { 
  // 设置下游
  public BasicFuseableObserver(Observer<? super R> downstream) {
        this.downstream = downstream;
    }
  @Override
    public final void onSubscribe(Disposable d) {
      //验证过上游
        if (DisposableHelper.validate(this.upstream, d)) {
						// 设置上游
            this.upstream = d;
            if (d instanceof QueueDisposable) {
                this.qd = (QueueDisposable<T>)d;
            }

            if (beforeDownstream()) {

                downstream.onSubscribe(this);

                afterDownstream();
            }

        }
    }
  // dispose也是拿到上游的disposed进行取消，几乎等同于直接拿到上游的对象进行取消
  // map只是通过包装在消息传达时多做一些操作符操作而已
   @Override
    public void dispose() {
        upstream.dispose();
    }
}
```

### 有后续有延迟的任务如何取消

Observable 

```kotlin
    public final Observable<T> delay(long time, @NonNull TimeUnit unit, @NonNull Scheduler scheduler, boolean delayError) {
        Objects.requireNonNull(unit, "unit is null");
        Objects.requireNonNull(scheduler, "scheduler is null");

        return RxJavaPlugins.onAssembly(new ObservableDelay<>(this, time, unit, scheduler, delayError));
    }
```

ObservableDelay

```kotlin
public final class ObservableDelay<T> extends AbstractObservableWithUpstream<T, T> {
  
   public void subscribeActual(Observer<? super T> t) {
        Observer<T> observer;
        if (delayError) {
            observer = (Observer<T>)t;
        } else {
            observer = new SerializedObserver<>(t);
        }
				// 线程调度器，创建延迟任务
        Scheduler.Worker w = scheduler.createWorker();

        source.subscribe(new DelayObserver<>(observer, delay, unit, w, delayError));
    }
  
      static final class DelayObserver<T> implements Observer<T>, Disposable {
        final Observer<? super T> downstream;
        final long delay;
        final TimeUnit unit;
        final Scheduler.Worker w;
        final boolean delayError;

        Disposable upstream;

        DelayObserver(Observer<? super T> actual, long delay, TimeUnit unit, Worker w, boolean delayError) {
            super();
            this.downstream = actual;
            this.delay = delay;
            this.unit = unit;
            this.w = w;
            this.delayError = delayError;
        }
				// 上游下游的连接
        @Override
        public void onSubscribe(Disposable d) {
          // 验证上游
            if (DisposableHelper.validate(this.upstream, d)) {
              //上游赋值
                this.upstream = d;
              //调用下游的onSubscribe 订阅流程，传递的对象是自身（继承了Disposeable对象）
                downstream.onSubscribe(this);
            }
        }
         @Override
        public void onNext(final T t) {
           // 延迟调度器进行调度
            w.schedule(new OnNext(t), delay, unit);
        }

        @Override
        public void onError(final Throwable t) {
            // 延迟调度器进行调度
            w.schedule(new OnError(t), delayError ? delay : 0, unit);
        }
        @Override
        public void dispose() {
            // 上游取消，不要在发消息了
            upstream.dispose();
						// 延迟调度器也取消，有下游的消息也不要再发了
            w.dispose();
        }
      }

```



## 线程调度器

### subscribeOn()

#### 原理

在 Scheduler 指定的线程里启动 subscribe()

#### 效果

- 切换起源 Observable 的线程（也就是下游订阅上游事件的时候切线程）;
- 当多次调用 subscribeOn() 的时候，只有最上面的会对起源 Observable 起作用。

![image-20210830155354768](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210830155354768.png)

```kotlin
public final class SingleSubscribeOn<T> extends Single<T> {
    final SingleSource<? extends T> source;

    final Scheduler scheduler;

    public SingleSubscribeOn(SingleSource<? extends T> source, Scheduler scheduler) {
        this.source = source;
        this.scheduler = scheduler;
    }

    @Override
    protected void subscribeActual(final SingleObserver<? super T> observer) {
        final SubscribeOnObserver<T> parent = new SubscribeOnObserver<>(observer, source);
        observer.onSubscribe(parent);
				// 核心方法 切换线程，parent是runnable接口
        Disposable f = scheduler.scheduleDirect(parent);
				// 将上游的disposable对象替换为本地的disposable代理类
        parent.task.replace(f);

    }

    static final class SubscribeOnObserver<T>
    extends AtomicReference<Disposable>
    implements SingleObserver<T>, Disposable, Runnable {

        private static final long serialVersionUID = 7000911171163930287L;

        final SingleObserver<? super T> downstream;

        final SequentialDisposable task;

        final SingleSource<? extends T> source;

        SubscribeOnObserver(SingleObserver<? super T> actual, SingleSource<? extends T> source) {
            this.downstream = actual;
            this.source = source;
          	//task 被赋值，SequentialDisposable 也是个代理类，不执行实际逻辑
            this.task = new SequentialDisposable();
        }

        @Override
        public void onSubscribe(Disposable d) {
          // disposable实际赋值，上游传递来的disposable
            DisposableHelper.setOnce(this, d);
        }

        @Override
        public void onSuccess(T value) {
            downstream.onSuccess(value);
        }

        @Override
        public void onError(Throwable e) {
            downstream.onError(e);
        }

        @Override
        public void dispose() {
           // 通知上游的disposeable取消任务
            DisposableHelper.dispose(this);
           // 通知内部取消任务
            task.dispose();
        }

        @Override
        public boolean isDisposed() {
            return DisposableHelper.isDisposed(get());
        }

        @Override
        public void run() {
          // 切换线程后对上游进行订阅
            source.subscribe(this);
        }
    }

```

```kotlin
public final class SequentialDisposable
extends AtomicReference<Disposable>
implements Disposable {

    private static final long serialVersionUID = -754898800686245608L;

    public SequentialDisposable() {
        // nothing to do
    }

    
    public SequentialDisposable(Disposable initial) {
        lazySet(initial);
    }

    
    public boolean update(Disposable next) {
        return DisposableHelper.set(this, next);
    }

   
    public boolean replace(Disposable next) {
        return DisposableHelper.replace(this, next);
    }

    @Override
    public void dispose() {
        DisposableHelper.dispose(this);
    }

    @Override
    public boolean isDisposed() {
        return DisposableHelper.isDisposed(get());
    }
}
```

若多次调用subscribeOn方法切换线程，只会有一个线程影响任务的执行，多次调用是没有用的

![image-20210830155602490](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210830155602490.png)



### observeOn()

```kotlin
public final class SingleObserveOn<T> extends Single<T> {

    final SingleSource<T> source;

    final Scheduler scheduler;

    public SingleObserveOn(SingleSource<T> source, Scheduler scheduler) {
        this.source = source;
        this.scheduler = scheduler;
    }

    @Override
    protected void subscribeActual(final SingleObserver<? super T> observer) {
       	// 订阅过程不切线程
        source.subscribe(new ObserveOnSingleObserver<>(observer, scheduler));
    }

    static final class ObserveOnSingleObserver<T> extends AtomicReference<Disposable>
    implements SingleObserver<T>, Disposable, Runnable {
        private static final long serialVersionUID = 3528003840217436037L;

        final SingleObserver<? super T> downstream;

        final Scheduler scheduler;

        T value;
        Throwable error;

        ObserveOnSingleObserver(SingleObserver<? super T> actual, Scheduler scheduler) {
            this.downstream = actual;
            this.scheduler = scheduler;
        }

        @Override
        public void onSubscribe(Disposable d) {
           // 订阅过程，不切换线程
            if (DisposableHelper.setOnce(this, d)) {
               //赋值dispose（来自上游的disposable），
              //实际上下游取消的时候就会取消掉上游的任务（因为没有切换线程）
                downstream.onSubscribe(this);
            }
        }

        @Override
        public void onSuccess(T value) {
          // 上游事件到达后切线程
            this.value = value;
          // 收到线程后再取消，将内部的disposable替换成切线程的任务
          // 不需要通知上游，直接取消即可
            Disposable d = scheduler.scheduleDirect(this);
            DisposableHelper.replace(this, d);
        }

        @Override
        public void onError(Throwable e) {
          // 事件到达后切线程
            this.error = e;
          // 事件到达后取消的是切线程
            Disposable d = scheduler.scheduleDirect(this);
          // 将disposable替换呢为b
            DisposableHelper.replace(this, d);
        }

        @Override
        public void run() {
            Throwable ex = error;
            if (ex != null) {
                downstream.onError(ex);
            } else {
                downstream.onSuccess(value);
            }
        }

        @Override
        public void dispose() {
            DisposableHelper.dispose(this);
        }

        @Override
        public boolean isDisposed() {
            return DisposableHelper.isDisposed(get());
        }
    }
}
```

#### 原理

在内部创建的 Observer 的 onNext() onError() onSuccess() 等回调方法里，通过 Scheduler 指定的线程来调用下级 Observer 的对应回调方法

在任务下发到下游的时候才切线程，订阅上游事件的时候不切线程

![image-20210830155936495](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210830155936495.png)

#### 效果

切换 observeOn() 下面的 Observer 的回调所在的线程
 当多次调用 observeOn() 的时候，每个都会进行一次线程切换，影响范围是它 下面的每个 Observer (除非又遇到新的 observeOn())

![image-20210826174959565](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210826174959565.png)

### Scheduler 的原理

1. Schedulers.newThread() 和 Schedulers.io():

	- 当 scheduleDirect() 被调用的时候，会创建一个 Worker，Worker 的内部 会有一个 Executor，由 Executor 来完成实际的线程切换; 
	- scheduleDirect() 还会创建出一个 Disposable 对象，交给外层的 Observer，让它能执行 dispose() 操作，取消订阅链;
	- newThread() 和 io() 的区别在于，io() 可能会对 Executor 进行重用。

2. androidSchedulers.mainThread():

   通过内部的 Handler 把任务放到主线程去做。

Scheduler

```kotlin
 		@NonNull
    public Disposable scheduleDirect(@NonNull Runnable run, long delay, @NonNull TimeUnit unit) {
        final Worker w = createWorker();

        final Runnable decoratedRun = RxJavaPlugins.onSchedule(run);

        DisposeTask task = new DisposeTask(decoratedRun, w);

        w.schedule(task, delay, unit);

        return task;
    }
```
### Schedulers.newThread()和iSchedulers.io()

```kotlin
Single.just(1)
    .subscribeOn(Schedulers.newThread())//newThread()是io的基础
```

```java
public final class NewThreadScheduler extends Scheduler {
   ...
    @NonNull
    @Override
    public Worker createWorker() {
        return new NewThreadWorker(threadFactory);
    }
}
```

```java
public class NewThreadWorker extends Scheduler.Worker implements Disposable {
    private final ScheduledExecutorService executor;

    volatile boolean disposed;
		//包含一个executor进行线程调度，每次都会用全新的executor
    public NewThreadWorker(ThreadFactory threadFactory) {
        executor = SchedulerPoolFactory.create(threadFactory);
    }
     ...
```

```java
public final class SchedulerPoolFactory {
  public static ScheduledExecutorService create(ThreadFactory factory) {
        final ScheduledExecutorService exec = Executors.newScheduledThreadPool(1, factory);
        tryPutIntoPool(PURGE_ENABLED, exec);
        return exec;
    }
```

```java
public final class IoScheduler extends Scheduler {
  	...
		@NonNull
    @Override
    public Worker createWorker() {
        return new EventLoopWorker(pool.get());
    }  
   ...
    static final class EventLoopWorker extends Scheduler.Worker {
        private final CompositeDisposable tasks;
      // Executor 重用池，newThread是没有重用池的，这就是io和newThread的区别
        private final CachedWorkerPool pool;
        private final ThreadWorker threadWorker;

        final AtomicBoolean once = new AtomicBoolean();

        EventLoopWorker(CachedWorkerPool pool) {
            this.pool = pool;
            this.tasks = new CompositeDisposable();
            this.threadWorker = pool.get();
        }
    ....
  static final class ThreadWorker extends NewThreadWorker {
			// 继承了NewThreadWork
        long expirationTime;

        ThreadWorker(ThreadFactory threadFactory) {
            super(threadFactory);
            this.expirationTime = 0L;
        }

        public long getExpirationTime() {
            return expirationTime;
        }

        public void setExpirationTime(long expirationTime) {
            this.expirationTime = expirationTime;
        }
    }
}
  
```
### 切到主线程
```kotlin
Single.just(1)
    .observeOn(AndroidSchedulers.mainThread())
```

```java
public final class AndroidSchedulers {

    private static final class MainHolder {
        static final Scheduler DEFAULT
            = new HandlerScheduler(new Handler(Looper.getMainLooper()), true);
...
```

```java
final class HandlerScheduler extends Scheduler {
    @Override
    @SuppressLint("NewApi") // Async will only be true when the API is available to call.
    public Disposable scheduleDirect(Runnable run, long delay, TimeUnit unit) {
        if (run == null) throw new NullPointerException("run == null");
        if (unit == null) throw new NullPointerException("unit == null");

        run = RxJavaPlugins.onSchedule(run);
        ScheduledRunnable scheduled = new ScheduledRunnable(handler, run);
        Message message = Message.obtain(handler, scheduled);
        if (async) {
            message.setAsynchronous(true);
        }
        //使用handler切回到主线程
        handler.sendMessageDelayed(message, unit.toMillis(delay));
        return scheduled;
    }
```


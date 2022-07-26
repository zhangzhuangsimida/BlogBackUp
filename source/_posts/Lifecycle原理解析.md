---
title: Lifecycle原理解析
date: 2021-12-03 09:12:00
categories:
- Android
- JetPack
tags:
- Android
- JetPack
---
<!-- more -->
# Lifecycle原理解析

## 什么是Lifecycle

**具备宿主声明后期感知能力的组件。**

- 特性：它持有组件（如 Activity 或 Fragment）生命周期状态的信息，并且允许其他对象观察此状态。

- 添加依赖

```groovy
api 'androidx.appcompat:appcompat:1.1.0'
api 'androidx.lifecycler:lifecycle-common:2.1.0'
```

<!--more-->



## 如何使用Lifecycle观察宿主状态

有三种方法，继承LifecycleObserver，FullLifecyclerObserver或LifecycleEventObserver，三种方法无论哪种方式都需要在宿主中注册一下观察者。

- 经典用法，实现LifecycleObserver

```java
public class Fragment implements xxx, LifecycleOwner {
LifecycleRegistry mLifecycleRegistry = new LifecycleRegistry(this);
    @Override
    public Lifecycle getLifecycle() {
        return mLifecycleRegistry;
    }
}

class MyPresenter extends LifecycleObserver{
    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    void onCreate(@NotNull LifecycleOwner owner){}

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    void onDestroy(@NotNull LifecycleOwner owner){
      
    }
}

getLifecycle().addObserver(mPresenter);//注册观察者,观察宿主生命周期状态变化

```

继承LifecycleObserver，用注解的方式标记在每个方法上面，来观察宿主的生命周期变化的事件

```java
//1. 自定义的LifecycleObserver观察者，用注解声明每个方法观察的宿主的状态
class LocationObserver extends LifecycleObserver{
    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    void onStart(@NotNull LifecycleOwner owner){
      //开启定位
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    void onStop(@NotNull LifecycleOwner owner){
       //停止定位
    }
}

//2. 注册观察者,观察宿主生命周期状态变化
class MyFragment extends Fragment{
  public void onCreate(Bundle bundle){
    
    MyLifecycleObserver observer =new MyLifecycleObserver()
    getLifecycle().addObserver(observer);
    
  }
}

```

- FullLifecyclerObserver

```java
interface FullLifecycleObserver extends LifecycleObserver {
    void onCreate(LifecycleOwner owner);
    void onStart(LifecycleOwner owner);
    void onResume(LifecycleOwner owner);
    void onPause(LifecycleOwner owner);
    void onStop(LifecycleOwner owner);
    void onDestroy(LifecycleOwner owner);
}
class LocationObserver extends FullLifecycleObserver{
    void onStart(LifecycleOwner owner){}
    void onStop(LifecycleOwner owner){}
}
```

- LifecycleEventObserver

```java
public interface LifecycleEventObserver extends LifecycleObserver {
  // 所有生命周期发生变化的事件都会发送到这里
    void onStateChanged(LifecycleOwner source, Lifecycle.Event event);
}

class LocationObserver extends LifecycleEventObserver{
    @override
    void onStateChanged(LifecycleOwner source, Lifecycle.Event event){
      //需要自行判断life-event是onstart, 还是onstop等事件
    }
}
```

推荐使用2，3种方法，不需要注解

## Fragment如何实现Lifecycle

```java
// 实现 LifecycleOwner 表示它是一个宿主
public class Fragment implements LifecycleOwner {
LifecycleRegistry mLifecycleRegistry = new LifecycleRegistry(this);
  // 必须复写getLifecycle()，
  // Lifecycle是 LifecycleRegistry的父类，这里是一种面向接口的思想
  // 实际上我们注册Lifecycle的时候，都注册在LifecycleRegistry这个类中去了
  @Override
  public Lifecycle getLifecycle() {  
      //复写自LifecycleOwner,所以必须new LifecycleRegistry对象返回
      return mLifecycleRegistry;
  }
// Fragment的每个生命周期的方法中，会让mLifecycleRegistry分发自己的状态到每一个观察者。
// 从而实现观察生命周期变化的能力
void performCreate(){
     mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);
  }
  
 void performStart(){
     mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START);
  }
  .....
 void performResume(){
     mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
  }  
}
```

## LifecycleOwner、Lifecycle、LifecycleRegistry的关系

![image-20211203102141678](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20211203102141678.png)

- **LifecycleOwner**代表宿主，一般指Activity和Framgent，因为它们都实现了**LifecycleOwner**接口，当然我们也可以自己实现一个类实现接口让它成为生命周期的宿主，让其他观察者观察它的生命周期。

- **LifecycleRegistry**宿主复写了**LifecycleOwner**接口，必然要实现**getLifecycle**方法并且返回一个**Lifecycle**对象，它实际上是**LifecycleRegistry**，只不过采用了面向接口的编程方式。

- 我们向LifecycleRegistry注册观察着的时候它可以是

  - LifecycleObserver
  - FullLifecycleObserver
  - LifecycleEventObserver

  它会在每个生命周期方法中让**LifecycleRegistry**发送事件给每个观察者

## Activity如何实现Lifecycle

```java
//我们通常使用的AppCompenentActivity是 ComponentActivity的子类
//和Fragment的一样，Activity同样实现了LifecycleOwner接口，来声明它是一个宿主
public class ComponentActivity extends Activity implements LifecycleOwner{
  private LifecycleRegistry mLifecycleRegistry = new LifecycleRegistry(this);
  // 复写getLifecycle() 返回一个Lifecycle对象（实际是LifecycleRegistry对象）
   @NonNull
   @Override
   public Lifecycle getLifecycle() {
      return mLifecycleRegistry;
   }
  
  protected void onCreate(Bundle bundle) {
      super.onCreate(savedInstanceState);
    	//并没有像Fragment一样，在生命周期中用实际是LifecycleRegistry向观察者分发状态
      //往Activity上添加一个fragment,用以报告生命周期的变化
      //目的是为了兼顾不是继承自AppCompactActivity的场景.
      ReportFragment.injectIfNeededIn(this); 
}

```

ReportFragment

```java
public class ReportFragment extends Fragment{
  // 将不可见的Fragment注入activity中
  public static void injectIfNeededIn(Activity activity) {
        android.app.FragmentManager manager = activity.getFragmentManager();
        if (manager.findFragmentByTag(REPORT_FRAGMENT_TAG) == null) {
            manager.beginTransaction().add(new ReportFragment(), REPORT_FRAGMENT_TAG).commit();
            manager.executePendingTransactions();
        }
  }
	//生命周期中调用dispatch方法
    @Override
    public void onStart() {
        super.onStart();
        dispatch(Lifecycle.Event.ON_START);
    }

    @Override
    public void onResume() {
        super.onResume();
        dispatch(Lifecycle.Event.ON_RESUME);
    }

    @Override
    public void onPause() {
        super.onPause();
        dispatch(Lifecycle.Event.ON_PAUSE);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        dispatch(Lifecycle.Event.ON_DESTROY);
    }
	// 拿到activity的LifecycleRegistry类，并分发状态
    private void dispatch(Lifecycle.Event event) {
         Lifecycle lifecycle = activity.getLifecycle();
         if (lifecycle instanceof LifecycleRegistry) {
             ((LifecycleRegistry) lifecycle).handleLifecycleEvent(event);
         }
}
```

## Lifecycle是如何分发宿主状态的

LifecycleRegistry

```java
public class LifecycleRegistry extends Lifecycle {
  
		// 添加观察者时，生命周期事件 分发的流程
 		@Override
    public void addObserver(@NonNull LifecycleObserver observer) {
      // 得到一个 initialState对象
      // State指的是当前宿主的状态
      // 只要不是在DESTROYED下注册，初始状态都是INITIALIZED
        State initialState = mState == DESTROYED ? DESTROYED : INITIALIZED;
      // 将observer封装成一个ObserverWithState（拥有宿主状态的观察者）
      // 这里仅仅是简单的包装了一下并且把当前的状态传递了进去
        ObserverWithState statefulObserver = new ObserverWithState(observer, initialState);
      // statefulObserver添加到map集合当中
        ObserverWithState previous = mObserverMap.putIfAbsent(observer, statefulObserver);

      ...
      // 让观察者当前的状态琮INITIALIZED前进到宿主当前的状态
      // 在onResume中注册观察者，onCreate，onStart状态都会接收
      // 无论在哪里注册，你都能收到生命周期内完整的状态变化  
        boolean isReentrance = mAddingObserverCounter != 0 || mHandlingEvent;
      // 通过calculateTargetState() 去计算出observer应该到达的状态（当前状态）
        State targetState = calculateTargetState(observer);
        mAddingObserverCounter++;
      // 观察者的状态和target比较
      // statefulObserver.mState.compareTo(targetState)<0 
      // 代表观察者的状态 没有到达target的状态
        while ((statefulObserver.mState.compareTo(targetState) < 0
                && mObserverMap.contains(observer))) {
            pushParentState(statefulObserver.mState);
         // 实现生命周期前进
         // 调用封装的 observer 分发事件
         // 根据状态分发事件
         //1. upEvent  方法会让观察者根据状态决定应该接收哪个事件
         //2. dispatchEvent ,根据当前接收的事件，反推出一个新状态（状态前进了一步）
         //3. 调用dispatchEvent/LifecycleObserver.onStateChanged(owner, event);
         // 再次分发新的状态 直到观察者和 分发者状态一致
            statefulObserver.dispatchEvent(lifecycleOwner, upEvent(statefulObserver.mState));
            popParentState();
            // mState / subling may have been changed recalculate
            targetState = calculateTargetState(observer);
        }

        if (!isReentrance) {
            // we do sync only on the top level.
            sync();
        }
        mAddingObserverCounter--;
    }
  
  	// 通过当前观察者的状态去判断应该接收哪个事件
    private static Event upEvent(State state) {
        switch (state) {
            // 创建之初是 INITIALIZED ，应该接收 ON_CREATE 事件
            case INITIALIZED:
            case DESTROYED:
                return ON_CREATE;
            case CREATED:
                return ON_START;
            case STARTED:
                return ON_RESUME;
            case RESUMED:
                throw new IllegalArgumentException();
        }
        throw new IllegalArgumentException("Unexpected state value " + state);
    } 
  
    static class ObserverWithState {
     		State mState;
        LifecycleEventObserver mLifecycleObserver;

        ObserverWithState(LifecycleObserver observer, State initialState) {
          // Lifecycling是区分observer是LifecycleObserver，FullLifecyclerObserver或LifecycleEventObserver的核心
          // Lifecycling是一个工具类，使用适配器模式将observer转换成 LifecycleEventObserver
            mLifecycleObserver = Lifecycling.lifecycleEventObserver(observer);
            mState = initialState;
        }
			
        void dispatchEvent(LifecycleOwner owner, Event event) {
          // 根据当前的Event事件，反推出一个新的state
            State newState = getStateAfter(event);
            mState = min(mState, newState);
          // 分发当前的状态
            mLifecycleObserver.onStateChanged(owner, event);
            mState = newState;
        }
    }  
  
    static State getStateAfter(Event event) {
      // 当前接收事件 ON_CREATE ,现在状态应该是CREATED
        switch (event) {
            case ON_CREATE:
            case ON_STOP:
                return CREATED;
            case ON_START:
            case ON_PAUSE:
                return STARTED;
            case ON_RESUME:
                return RESUMED;
            case ON_DESTROY:
                return DESTROYED;
            case ON_ANY:
                break;
        }
        throw new IllegalArgumentException("Unexpected event value " + event);
    } 
  
  // 宿主生命周期变化之后分发给观察者
    public void handleLifecycleEvent(@NonNull Lifecycle.Event event) {
       // 根据事件，推导出每个观察者应该到达的下一个生命周期状态
        State next = getStateAfter(event);
        moveToState(next);
    } 
    private void moveToState(State next) {
       ... 
      // 其他逻辑都是一些状态的判断，分发逻辑在sync
        sync();
        ...
    }
    private void sync() {
       
				//!isSynced() 方法：在mObserverMap集合中注册的observer，是不是所有的观察者的状态都分发完了，同步到和宿主一致的状态，若没有，则继续执行
        while (!isSynced()) {
            mNewEventOccurred = false;
				// 比较每个观察者和宿主之间的状态， < 0 代表宿主生命周期状态小于观察者的状态，此时处于生命周期倒退的阶段
        // 比如宿主从前台切换到了后台，执行onPause 方法，宿主进入STARTED状态，观察者此时还是RESUMED状态
            if (mState.compareTo(mObserverMap.eldest().getValue().mState) < 0) {
              // 集合中所有的观察者都倒退到和宿主一样的状态
                backwardPass(lifecycleOwner);
            }
            Entry<LifecycleObserver, ObserverWithState> newest = mObserverMap.newest();
        // 比较每个观察者和宿主之间的状态 ,>0 代表宿主生命周期状态大于观察者的状态，此时处于生命周期前进的阶段
            if (!mNewEventOccurred && newest != null
                    && mState.compareTo(newest.getValue().mState) > 0) {
              // 集合中所有的观察者都前进到和宿主一样的状态              
                forwardPass(lifecycleOwner);
            }
        }
        mNewEventOccurred = false;
    }  
    // 生命周期后退
    private void backwardPass(LifecycleOwner lifecycleOwner) {
        ...
        while (descendingIterator.hasNext() && !mNewEventOccurred) {
            Entry<LifecycleObserver, ObserverWithState> entry = descendingIterator.next();
            ObserverWithState observer = entry.getValue();
            while ((observer.mState.compareTo(mState) > 0 && !mNewEventOccurred
                    && mObserverMap.contains(entry.getKey()))) {
              // 根据 观察者当前的状态计算出应该分发的事件
              // 因为是生命周期的倒退，这里用的是downEvent
                Event event = downEvent(observer.mState);
                pushParentState(getStateAfter(event));
              // 将事件分发给 observer，并且根据当前事件推导出新的状态，
              // 直到所有观察者的状态和宿主一致，退出循环              
                observer.dispatchEvent(lifecycleOwner, event);
                popParentState();
            }
        }
    }  
  
    private static Event downEvent(State state) {
        switch (state) {
            case INITIALIZED:
                throw new IllegalArgumentException();
            case CREATED:
                return ON_DESTROY;
            case STARTED:
                return ON_STOP;
            case RESUMED:
                return ON_PAUSE;
            case DESTROYED:
                throw new IllegalArgumentException();
        }
        throw new IllegalArgumentException("Unexpected state value " + state);
    }
    // 生命周期前进  
    private void forwardPass(LifecycleOwner lifecycleOwner) {
        Iterator<Entry<LifecycleObserver, ObserverWithState>> ascendingIterator =
                mObserverMap.iteratorWithAdditions();
        while (ascendingIterator.hasNext() && !mNewEventOccurred) {
            Entry<LifecycleObserver, ObserverWithState> entry = ascendingIterator.next();
            ObserverWithState observer = entry.getValue();
            while ((observer.mState.compareTo(mState) < 0 && !mNewEventOccurred
                    && mObserverMap.contains(entry.getKey()))) {
                pushParentState(observer.mState);
              // 根据 观察者当前的状态计算出应该分发的事件
              // 因为是生命周期的前进，这里用的是upEvent
              // 最后将事件分发给 observer，并且根据当前事件推导出新的状态
              // 直到所有观察者的状态和宿主一致，退出循环
                observer.dispatchEvent(lifecycleOwner, upEvent(observer.mState));
                popParentState();
            }
        }
    }
  
}
```

State

```java
public abstract class Lifecycle {
   @SuppressWarnings("WeakerAccess")
  // event 和生命周期相同，state状态和生命周期并不是相同的
    public enum Event {
       
        ON_CREATE,
        
        ON_START,
      
        ON_RESUME,
       
        ON_PAUSE,
      
        ON_STOP,
       
        ON_DESTROY,
  
        ON_ANY
    }

// 状态（枚举）
public enum State {

    DESTROYED,
  
    INITIALIZED,

    CREATED,

    STARTED,

    RESUMED;

    public boolean isAtLeast(@NonNull State state) {
        return compareTo(state) >= 0;
    }
}
}
```

Lifecycling

```java
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP_PREFIX)
public class Lifecycling {	
 		@NonNull
    static LifecycleEventObserver lifecycleEventObserver(Object object) {
      	// 判断observer是否实现了LifecycleEventObserver接口
        boolean isLifecycleEventObserver = object instanceof LifecycleEventObserver;
      	// 判断observer是否实现了FullLifecycleObserver接口
        boolean isFullLifecycleObserver = object instanceof FullLifecycleObserver;
      
        // 通过FullLifecycleObserverAdapter 对生命周期的各种Event回调
        
        // 若observer 同时实现了LifecycleEventObserver 和 FullLifecycleObserver
        if (isLifecycleEventObserver && isFullLifecycleObserver) {
            return new FullLifecycleObserverAdapter((FullLifecycleObserver) object,
                    (LifecycleEventObserver) object);
        }
        // 只实现了FullLifecycleObserver的observer
        if (isFullLifecycleObserver) {
            return new FullLifecycleObserverAdapter((FullLifecycleObserver) object, null);
        }
        // 只实现了isLifecycleEventObserver的observer
        if (isLifecycleEventObserver) {
            return (LifecycleEventObserver) object;
        }
				// 若observer仅仅实现了 LifecycleObserver，就要通过反射或者依赖包来实现
        // 因为LifecycleObserver是空实现，仅仅是作为一种规范和约束，
        // 所以对于只实现了 LifecycleObserver的观察者，有两种方法来实现事件的通知
        // 1. 
        final Class<?> klass = object.getClass();
        int type = getObserverConstructorType(klass);
        if (type == GENERATED_CALLBACK) {
            List<Constructor<? extends GeneratedAdapter>> constructors =
                    sClassToAdapters.get(klass);
            if (constructors.size() == 1) {
                GeneratedAdapter generatedAdapter = createGeneratedAdapter(
                        constructors.get(0), object);
                return new SingleGeneratedAdapterObserver(generatedAdapter);
            }
            GeneratedAdapter[] adapters = new GeneratedAdapter[constructors.size()];
            for (int i = 0; i < constructors.size(); i++) {
                adapters[i] = createGeneratedAdapter(constructors.get(i), object);
            }
          // 如果使用了 lifecycle-compiler 依赖 ，compiler是编译的意思，里面包含一个注解处理器啊，它会在编译阶段生成适配的类	
          // 如果使用了这个依赖，就不需要利用反射实现这些方法了
            return new CompositeGeneratedAdaptersObserver(adapters);
        }
      // 用nvokeMethod 方法，反射的方式调用自定义的观察者当中的相关方法
        return new ReflectiveGenericLifecycleObserver(object);
    }
  
    private static GeneratedAdapter createGeneratedAdapter(
            Constructor<? extends GeneratedAdapter> constructor, Object object) {
       ....
    }
   // 若没有 lifecycle-compiler依赖，

    @Nullable
    private static Constructor<? extends GeneratedAdapter> generatedConstructor(Class<?> klass) {
       // klass 对象就是observer
        try {
           //得到包名
            Package aPackage = klass.getPackage();
           // 得到类名
            String name = klass.getCanonicalName();
            final String fullPackage = aPackage != null ? aPackage.getName() : "";
           //adaptername 就是全类名+"_LifecycleAdapter"
            final String adapterName = getAdapterName(fullPackage.isEmpty() ? name :
                    name.substring(fullPackage.length() + 1));
						
            @SuppressWarnings("unchecked") final Class<? extends GeneratedAdapter> aClass =
                    (Class<? extends GeneratedAdapter>) Class.forName(
                            fullPackage.isEmpty() ? adapterName : fullPackage + "." + adapterName);
            //反射加载这个类getDeclaredConstructor 
            //若这个阶段没有异常说明这个类是存在的，也就说明依赖了这个compiler编译器
            //若抛出异常证明没有引用
            Constructor<? extends GeneratedAdapter> constructor =
                    aClass.getDeclaredConstructor(klass);
            if (!constructor.isAccessible()) {
                constructor.setAccessible(true);
            }
            return constructor;
        } catch (ClassNotFoundException e) {
            return null;
        } catch (NoSuchMethodException e) {
            // this should not happen
            throw new RuntimeException(e);
        }
    }
    public static String getAdapterName(String className) {
        return className.replace(".", "_") + "_LifecycleAdapter";
    }
}
```

FullLifecycleObserverAdapter

```java
class FullLifecycleObserverAdapter implements LifecycleEventObserver {

    private final FullLifecycleObserver mFullLifecycleObserver;
    private final LifecycleEventObserver mLifecycleEventObserver;

    FullLifecycleObserverAdapter(FullLifecycleObserver fullLifecycleObserver,
            LifecycleEventObserver lifecycleEventObserver) {
        mFullLifecycleObserver = fullLifecycleObserver;
        mLifecycleEventObserver = lifecycleEventObserver;
    }
		/// 给 FullLifecycleObserver 传 Event
    @Override
    public void onStateChanged(LifecycleOwner source, Lifecycle.Event event) {
        switch (event) {
            case ON_CREATE:
                mFullLifecycleObserver.onCreate(source);
                break;
            case ON_START:
                mFullLifecycleObserver.onStart(source);
                break;
            case ON_RESUME:
                mFullLifecycleObserver.onResume(source);
                break;
            case ON_PAUSE:
                mFullLifecycleObserver.onPause(source);
                break;
            case ON_STOP:
                mFullLifecycleObserver.onStop(source);
                break;
            case ON_DESTROY:
                mFullLifecycleObserver.onDestroy(source);
                break;
            case ON_ANY:
                throw new IllegalArgumentException("ON_ANY must not been send by anybody");
        }
      
      // 给mLifecycleEventObserver 传Event
        if (mLifecycleEventObserver != null) {
            mLifecycleEventObserver.onStateChanged(source, event);
        }
    }
}
```



ReflectiveGenericLifecycleObserver

```java
class ReflectiveGenericLifecycleObserver implements LifecycleEventObserver {
    private final Object mWrapped;
    private final CallbackInfo mInfo;

    ReflectiveGenericLifecycleObserver(Object wrapped) {
        mWrapped = wrapped;
        mInfo = ClassesInfoCache.sInstance.getInfo(mWrapped.getClass());
    }

    @Override
    public void onStateChanged(LifecycleOwner source, Event event) {
        mInfo.invokeCallbacks(source, event, mWrapped);
    }
}
```

### 宿主生命周期和状态模型图

![image-20211203112115366](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20211203112115366.png)

- 添加observer时,完整的生命周期事件分发

![image-20211203162451814](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20211203162451814.png)


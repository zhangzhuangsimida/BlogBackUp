---
title: '自定义view布局02:View绘制流程'
date: 2021-09-07 17:58:44
categories:
- Android
- 自定义view
tags:
- Android
- 自定义view
---

# View 绘制流程



## View 绘制流程主要对象图示



![ ](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907180408351.png)





## View绘制流程函数调用

虚线表示至少一次消息处理(API29  之后)

![image-20210907180743677](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907180743677.png)



## Activity与View

Activity与View是通过PhoneWindow(Window) 对象关联的

Activity 与通过attach()方法Window（实际是PhoneWIndow）关联，

Window通过setContentView()与View关联

![image-20210908165219071](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210908165219071.png)

### Activity的实例化和生命周期

ActivityThread类负责实例化Acitivty类并调用Activity的生命周期方法

所谓的

ActivityThread类中的

- `handleLaunchActivity()`->`performLaunchActivity()`方法会实例化Activity对象并调用Activity对象的onCreate()
- `handleStartActivity()`方法调用Activity的onStart()
- `handleResumeActivity()`->` performResumeActivity()`方法调用Activity的`onResume()`

#### ActivityThread

```kotlin
		// 调用onCreate
		@Override
    public Activity handleLaunchActivity(ActivityClientRecord r,
            PendingTransactionActions pendingActions, Intent customIntent) {
		...                                         
         // 实例化Activity对象
        final Activity a = performLaunchActivity(r, customIntent);                                  		...
    }

    private Activity performLaunchActivity(ActivityClientRecord r, Intent customIntent) {
       ...
          Activity activity = null;
      		java.lang.ClassLoader cl = appContext.getClassLoader();
      			//调用Instrumentation.newActivity() 方法创建一个Activity对象并返回
            activity = mInstrumentation.newActivity(
                    cl, component.getClassName(), r.intent);
       ...
      // 调用activity  attach方法
      activity.attach(appContext,...);
     		 ...
      // 最终会调用 activity onCreate方法
      // 通过 Instrumentation.callActivityOnCreate() 调用
      // 所以可以看出Activity onCreate() 调用发生在 attach() 方法之后
      if (r.isPersistable()) {
                    mInstrumentation.callActivityOnCreate(activity, r.state, r.persistentState);
                } else {
                    mInstrumentation.callActivityOnCreate(activity, r.state);
                }
      return activity;
    }

		// 调用resume 
    @Override
    public void  (IBinder token, boolean finalStateRequest, boolean isForward,
            String reason) {
        ...
        // 调用Activity onResume方法
        final ActivityClientRecord r = performResumeActivity(token, finalStateRequest, reason);
				...
        if (r.window == null && !a.mFinished && willBeVisible) {
            // 也就是PhoneWindow
            r.window = r.activity.getWindow();
            View decor = r.window.getDecorView();
  					// 获得的是  WindowManagerImpl 
            ViewManager wm = a.getWindowManager();
            // 获得窗口属性
            WindowManager.LayoutParams l = r.window.getAttributes();
            a.mDecor = decor;
           
            ...
            if (a.mVisibleFromClient) {
                if (!a.mWindowAdded) {
                    a.mWindowAdded = true;
                  // 将decorView窗口属性放进去
                  // 使用的是 WindowManagerImpl 的addView 方法
                    wm.addView(decor, l);
                } else {
                    // The activity will get a callback for this {@link LayoutParams} change
                    // earlier. However, at that time the decor will not be set (this is set
                    // in this method), so no action will be taken. This call ensures the
                    // callback occurs with the decor set.
                    a.onWindowAttributesChanged(l);
                }
            }
    }
      
	 @VisibleForTesting// 会调用 activity的onResume方法
    public ActivityClientRecord performResumeActivity(IBinder token, boolean finalStateRequest,
            String reason) {
     r.activity.performResume(r.startsNotResumed, reason);

    }
```

#### 实例化Activity

利用反射实例化Activity

##### Instrumentation.newActivity()

```java
public Activity newActivity(ClassLoader cl, String className,
        Intent intent)
        throws InstantiationException, IllegalAccessException,
        ClassNotFoundException {
    String pkg = intent != null && intent.getComponent() != null
            ? intent.getComponent().getPackageName() : null;
          // instantiateActivity方法 利用反射实例化Activity对象 
    return getFactory(pkg).instantiateActivity(cl, className, intent);
}

public @NonNull Activity instantiateActivity(@NonNull ClassLoader cl, @NonNull String className, @Nullable Intent intent)
            throws InstantiationException, IllegalAccessException, ClassNotFoundException {
       // 反射实例化Activity对象  
        return (Activity) cl.loadClass(className).newInstance();
}
```

### Activity生命周期方法

#### attach() 

它是Activity内部的初始化方法(activity对象创建出来后就马上调用)

`attach() `的调用发生在`onCreate()`之前

被`ActivityThread`调用，在` handleLaunchActivity()`-> ` -`> `activity.attach(appContext,...);`

```java
final void attach(Context context, ActivityThread aThread,
            Instrumentation instr, IBinder token, int ident,
            Application application, Intent intent, ActivityInfo info,
            CharSequence title, Activity parent, String id,
            NonConfigurationInstances lastNonConfigurationInstances,
            Configuration config, String referrer, IVoiceInteractor voiceInteractor,
            Window window, ActivityConfigCallback activityConfigCallback, IBinder assistToken) {
  	// Window 对象被赋值
    mWindow = new PhoneWindow(this, window, activityConfigCallback);
		...
      // 对Window设置WindowManager
        mWindow.setWindowManager(
                (WindowManager)context.getSystemService(Context.WINDOW_SERVICE),
                mToken, mComponent.flattenToString(),
                (info.flags & ActivityInfo.FLAG_HARDWARE_ACCELERATED) != 0);   
	  // 对Activity的 WindowManager赋值， get出来的是 WindowManagerImpl 
   mWindowManager = mWindow.getWindowManager();
}  
```

#### onCreate()

和attach()一样被ActivityThread调用，在

`ActivityThread.handleLaunchActivity()`-> `ActivityThread.performLaunchActivity()`->

`Instrumentation.callActivityOnCreate()`->`Activity.performCreate()`->`Activity.onCreate()`

##### Instrumentation.callActivityOnCreate()

```java
public void callActivityOnCreate(Activity activity, Bundle icicle,
        PersistableBundle persistentState) {
    ...
    //调用Acitivity 对象的 performCreate() 
    // performCreate() 会调用内部的onCreate方法
    activity.performCreate(icicle, persistentState);
   ...
}
```

##### Activity.performCreate()

```java
final void performCreate(Bundle icicle, PersistableBundle persistentState) {
       ...
  			// 调用onCreate方法
        if (persistentState != null) {
            onCreate(icicle, persistentState);
        } else {
            onCreate(icicle);
        }
        ..
    }
```

#### onResume()

`ActivityThread.handleResumeActivity()`->`ActivityThread.performResumeActivity()`->

`Activity.performResume()`->`Instrumentation.callActivityOnResume()`->`Activity.OnResume()`

##### Activity.performResume()

```java
final void performResume(boolean followedByPause, String reason) {
  ...
    mInstrumentation.callActivityOnResume(this);
  ...  
}
```

##### Instrumentation.callActivityOnResume()

```java
    public void callActivityOnResume(Activity activity) {
        activity.mResumed = true;
        activity.onResume();
        
        if (mActivityMonitors != null) {
            synchronized (mSync) {
                final int N = mActivityMonitors.size();
                for (int i=0; i<N; i++) {
                    final ActivityMonitor am = mActivityMonitors.get(i);
                    am.match(activity, activity, activity.getIntent());
                }
            }
        }
    }
```



### Activity.setContentView() 

Activity 设置布局是通过window（确切的说是PhoneWindow）对象连接的

```java
  public void setContentView(@LayoutRes int layoutResID) {
       // Activity 内部window是 PhoneWindow对象
        getWindow().setContentView(layoutResID);
        initWindowDecorActionBar();
    }
```



## Window&PhoneWindow

Window与View通过DecorVIew产生联系

Activity内部持有 mWindow对象，mWindow 依赖PhoneWindow对象

PhoneWindow持有mDecor对象，mDecor其实是DecorView对象（继承自FrameLayout）

![image-20210908165416162](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210908165416162.png)



### Window

#### Window.getLocalFeatures()

Windows的特征，Activity中调用的`requestWindowFeature(Window.FEATURE_NO_TITLE)`就是修改的这个值

**为什么requestWindowFeature() 方法要写在setContentView前面？**

因为setContentView() 要用到getLocalFeatures()的返回值

```java
protected final int getLocalFeatures()
{
    return mLocalFeatures;
}

```

#### findViewById

实际调用的是DecorView的findviewby，id，就是找到系统布局模版中id是@android:id/content的布局

```java
  public <T extends View> T findViewById(@IdRes int id) {
        return getDecorView().findViewById(id);
    }
```

#### getAttributes

窗口属性

```java
   
    private final WindowManager.LayoutParams mWindowAttributes =
        new WindowManager.LayoutParams();
       
    public LayoutParams() {
        super(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        type = TYPE_APPLICATION;
        format = PixelFormat.OPAQUE;
    }    
		public final WindowManager.LayoutParams getAttributes() {
        return mWindowAttributes;
    }
```

### setWindowManager

```java
public void setWindowManager(WindowManager wm, IBinder appToken, String appName,
        boolean hardwareAccelerated) {
   ...
     // 创建一个 WindowManagerImpl 对象
    mWindowManager = ((WindowManagerImpl)wm).createLocalWindowManager(this);
}
```

### PhoneWindow

Activity 调用 `setContentView(int layoutResID)`时实际调用的是`window.setContentView(int resId)`

而Activity 内部持有的是PhoneWindow对象的实例，所以其实调用的是PhonewIndow对象的方法

#### 调用installDecor()初始化的过程：

- 与DecorVIew建立联系

  实例化一个DecorView对象，交给PhoneWIndow

  `setContentView(int layoutResID)` ->`installDecor()`->` generateDecor(-1);`

- 帮助 DecorView 添加一个根布局（root）

  根据Window.getLocalFeatures()获得开发者配置的WIndow特性，选择不同的布局模板，交给DecorVIew创建根布局

   `setContentView(int layoutResID)` -> `installDecor();`->`generateLayout(mDecor)`

  -> ` mDecor.onResourcesLoaded(mLayoutInflater, layoutResource)`

![image-20210909142715857](../../../Library/Application Support/typora-user-images/image-20210909142715857.png)

- 将Activity 自定义的布局加入Decor的根布局中id为`@android:id/content`的FrameLayout中

  ![image-20210909150251632](../../../Library/Application Support/typora-user-images/image-20210909150251632.png)

```java
public class PhoneWindow extends Window implements MenuBuilder.Callback {  
  	// DecorView是 Window里面的顶层View
		private DecorView mDecor;
    @Override
    public void setContentView(int layoutResID) {
  			 // 初始化时 mContentParent 是 null
        if (mContentParent == null) {
           // 初始化Decor
            installDecor();
        }else if (!hasFeature(FEATURE_CONTENT_TRANSITIONS)) {
            mContentParent.removeAllViews();
        }

        if (hasFeature(FEATURE_CONTENT_TRANSITIONS)) {
            final Scene newScene = Scene.getSceneForLayout(mContentParent, layoutResID,
                    getContext());
            transitionTo(newScene);
        } else {
           // 将Activity的布局 layoutResID ，传入DecorView的根布局中
            
            mLayoutInflater.inflate(layoutResID, mContentParent);
        }
        mContentParent.requestApplyInsets();
        final Callback cb = getCallback();
        if (cb != null && !isDestroyed()) {
            cb.onContentChanged();
        }
       
 		}
   // 初始化 DecorView 并为它添加根布局
    private void installDecor() {
        mForceDecorInstall = false;
      
        if (mDecor == null) {
            // 创建 DecorView 对象 赋值给mDecor
            mDecor = generateDecor(-1);
            mDecor.setDescendantFocusability(ViewGroup.FOCUS_AFTER_DESCENDANTS);
            mDecor.setIsRootNamespace(true);
        }
       // 初始化时mContentParent是 null的
        if (mContentParent == null) {
          // 给mContentParent 赋值
          //generateLayout() 返回的是ID为 android.R.id.content的FrameLayout（系统模版布局中）
            mContentParent = generateLayout(mDecor); 
        }      
      ...
    }
    protected ViewGroup generateLayout(DecorView decor) {
      ...
       // 根据一些常用的配置进行设置
			if (a.getBoolean(R.styleable.Window_windowNoTitle, false)) {
            requestFeature(FEATURE_NO_TITLE);
        } else if (a.getBoolean(R.styleable.Window_windowActionBar, false)) {
            // Don't allow an action bar if there is no title.
            requestFeature(FEATURE_ACTION_BAR);
        }

        if (a.getBoolean(R.styleable.Window_windowActionBarOverlay, false)) {
            requestFeature(FEATURE_ACTION_BAR_OVERLAY);
        }  
      ...
       // Inflate the window decor.
       int layoutResource;
       // features调用Window.getLocalFeatures()
       int features = getLocalFeatures();
      // 
      // features 表示window的特性 ，比如有无title ，actionbar等
      // 根据 features 的不同对 layoutResource 赋值成不同的布局，就可以体现不同特性
      if ((features & ((1 << FEATURE_LEFT_ICON) | (1 << FEATURE_RIGHT_ICON))) != 0) {
          ...
        } else if ((features & ((1 << FEATURE_PROGRESS) | (1 << FEATURE_INDETERMINATE_PROGRESS))) != 0
                && (features & (1 << FEATURE_ACTION_BAR)) == 0) {
            ...
            layoutResource = R.layout.screen_progress;
           
        } 
         ...
        } else {
          	// 赋值 给  layoutResource 指定布局
            layoutResource = R.layout.screen_simple;
           
        }

        mDecor.startChanging();
  			// 通过传入的打气筒和 layoutResource，创建一个View命名为root
        //  mDecor通过addView(root) 将view对象添加到内部 
        mDecor.onResourcesLoaded(mLayoutInflater, layoutResource);
				// 调用的是window.findViewById()->DecorView.findViewById()
  			// 最终要找到的是系统模版中id是@android:id/content的ViewGroup
        ViewGroup contentParent = (ViewGroup)findViewById(ID_ANDROID_CONTENT);
        
  			// 根据配置做出一些设置
  				...
        if (getContainer() == null) 
            mDecor.setWindowBackground(mBackgroundDrawable);
            ...
            mDecor.setWindowFrame(frame);

        // 返回的是系统模板中id为android.R.id.content的FrameLayout  
        return contentParent;
    }    
}
```

#### screen_simple.xml 

android-sdk-macosx/platforms/android-30/data/res/layout/screen_simple.xml 

```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:fitsSystemWindows="true"
    android:orientation="vertical">
   <!-- Actionbar 的布局，ViewStub可以节约内存-->
    <ViewStub android:id="@+id/action_mode_bar_stub"
              android:inflatedId="@+id/action_mode_bar"
              android:layout="@layout/action_mode_bar"
              android:layout_width="match_parent"
              android:layout_height="wrap_content"
              android:theme="?attr/actionBarTheme" />
    <FrameLayout
         android:id="@android:id/content"
         android:layout_width="match_parent"
         android:layout_height="match_parent"
         android:foregroundInsidePadding="false"
         android:foregroundGravity="fill_horizontal|top"
         android:foreground="?android:attr/windowContentOverlay" />
</LinearLayout>
```



## DecorView

- 根据PhoneWindow 传递的根布局信息创建根布局

  `onResourcesLoaded()`

```java
public class DecorView extends FrameLayout implements RootViewSurfaceTaker, WindowCallbacks {
		// 创建DecorView实例
    protected DecorView generateDecor(int featureId) {
       ...
        // new 一个DecorView 对象
        return new DecorView(context, featureId, this, getAttributes());
    }
   // 将PhoneWindow根据window内部feature属性设置的根布局加入到DecorView内部 
   void onResourcesLoaded(LayoutInflater inflater, int layoutResource) {
      ...
        // 创建一个View对象，
        final View root = inflater.inflate(layoutResource, null);
        if (mDecorCaptionView != null) {
            if (mDecorCaptionView.getParent() == null) {
                addView(mDecorCaptionView,
                        new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT));
            }
            mDecorCaptionView.addView(root,
                    new ViewGroup.MarginLayoutParams(MATCH_PARENT, MATCH_PARENT));
        } else {

            //通过add View 将这系统模板布局View加入到DecorView里面
         
            addView(root, 0, new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        }
        mContentRoot = (ViewGroup) root;
        initializeElevation();
    }


}
```



## ViewRootImpl

DecorView的父View（其实不是一个View）

打印`println(window.decorView.parent.toString())`得到parent为ViewRootImpl

![image-20210909160559140](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210909160559140.png)

```java
public final class ViewRootImpl implements ViewParent,
        View.AttachInfo.Callbacks, ThreadedRenderer.DrawCallbacks { 
          
    final Thread mThread;
    final View.AttachInfo mAttachInfo;
          
    final ViewRootHandler mHandler = new ViewRootHandler();
    final class ViewRootHandler extends Handler { 
       @Override
        public String getMessageName(Message message) {...}
        @Override
        public void handleMessage(Message msg) { ...}
    }
   
          
    public ViewRootImpl(Context context, Display display, IWindowSession session,
            boolean useSfChoreographer) {  
    // 构造时赋值mThread对象
    // ViewRootImpl构造方法仅在WindowManagerGlobal中调用过
    // 调用它的方法是ActivityThread.performResumeActivity() ，所以mThread必然是主线程
    // checkThread()中将使用mThread  
    mThread = Thread.currentThread();
    // 创建对象，传入handler
    mAttachInfo = new View.AttachInfo(mWindowSession, mWindow, display, this, mHandler,    	this, context);  
    ...
    }        
    //检查线程    
    void checkThread() {
      // 判断   Thread.currentThread()是否和 mThread对象 相同
        if (mThread != Thread.currentThread()) {
            throw new CalledFromWrongThreadException(
                    "Only the original thread that created a view hierarchy can touch its views.");
        }
    }
		// 防止重复绘制的
    @Override
    public void requestLayout() {
      //mHandlingLayoutInLayoutRequest 标志位表示是否正在布局
        if (!mHandlingLayoutInLayoutRequest) {
            // 检查线程
            checkThread();
            mLayoutRequested = true;
            scheduleTraversals();
        }
    }
 	 public void setView(View view, WindowManager.LayoutParams attrs, View panelParentView,
            int userId) {
    // view 即为DecorView
     mView = view;
   ...
     // 第一次调用 requestLayout，是自主调用，不是成为其他View的Parent后被迫调用
     requestLayout();
     
     
     // 将ViewRootImpl 设置为DecorView的 Parent
     // 这样才能串联自定义布局->系统模板布局->DocerView-ViewRootImpl
     view.assignParent(this);
 	}  
          
   @UnsupportedAppUsage
   void scheduleTraversals() {
      ...
          // 向主线程post 一个 Runnable 对象： mTraversalRunnable, 
          // postCallback类似handler post，是一个异步操作
            mChoreographer.postCallback(
                    Choreographer.CALLBACK_TRAVERSAL, mTraversalRunnable, null);
            notifyRendererOfFramePending();
            pokeDrawLockIfNeeded();
     ..
    }
	 final class TraversalRunnable implements Runnable {
        @Override
        public void run() {
          // runnable 调用了doTraversal()方法
          // 因为被异步post ，所以doTraversal会在下次循环时调用
            doTraversal();
        }
    }
    void doTraversal() {
        // 下次循环调用的  performTraversals()
            performTraversals();
    } 
    // 核心方法 Traversals: 遍历
    // 生命周期就是拿着一个对象，调用对象上面的方法，
    // 这个方法也是依托顶层DecorView来出发（如同ActivityThread对应Activity生命周期方法的调用）
    // 它们是： performMeasure()， performLayout(), performDraw(),         
    private void performTraversals() {
      // 状态设置
			... 
        mIsInTraversal = true;
        mWillDrawSoon = true;
        boolean windowSizeMayChange = false;  
       // 1. 测量过程  调用decoerview.perform Measur() 先测量Window，再测量View树
                
      // 尺寸相关，窗口属性， 预定义宽高，
      // 如果是Activity它的值和 ActivityThread，WindowManager.addView() 的窗口属性是一样的
      WindowManager.LayoutParams lp = mWindowAttributes;
        int desiredWindowWidth;
        int desiredWindowHeight;
        if (mFirst) {
            mFullRedrawNeeded = true;
            // 第一次必然进入，  mLayoutRequested = true，布局必然重新布置
            mLayoutRequested = true;
           // 判断一下Window的级别         
            if (shouldUseDisplaySize(lp)) {
               ...
            } else {
               // Activity lp type参数是Application，而非系统窗口/键盘
              // 所以赋值为屏幕的宽高
                desiredWindowWidth = frame.width();
                desiredWindowHeight = frame.height();
            }
            //将DecorView依附到Window上
            //host 是DecorView
            host.dispatchAttachedToWindow(mAttachInfo, 0);
            
        } else { ...} 
         //传如DecorView，完成系统状态栏/导航栏的添加
					dispatchApplyInsets(host); 
            ...
       // View执行post操作时，若发生崩溃 AttachInfo == null，
       // 也就拿不到handler对象，可执行的runnable会暂时存在一个队列中
       // 此时就是执行队列中runnable的时机  
       getRunQueue().executeActions(mAttachInfo.mHandler);
          
      //  第一次绘执行performTravelsal  mLayoutRequested = true    
      //  mStopped只有Acitivity Stop的时候才为true  
      boolean layoutRequested = mLayoutRequested && (!mStopped || mReportNextDraw);
      if (layoutRequested) {
        ...
            // 第一次测量：对整个视图树的测量，是确定window的大小
            windowSizeMayChange |= measureHierarchy(host, lp, res,
                    desiredWindowWidth, desiredWindowHeight);
        ...
      }
      // 第一次执行必然进入
      if (mFirst || windowShouldResize || viewVisibilityChanged || cutoutChanged || params != null|| mForceNextWindowRelayout) {
          ...
           // 屏幕的宽高已经确定，但Window大小并不是应用层决定的，所有的服务都是系统服务WMS完成的，
           // 所以尺寸调整在relayoutWindow方法通知WMS，同时执行时我们的Window尺寸会从初识值变成固定值
           relayoutResult = relayoutWindow(params, viewVisibility, insetsPending);  
          ... 
             updatedConfiguration = true;
      }
      // mStopped只有Acitivity Stop的时候才为true，所以activity启动状态下一定为true
      if (!mStopped || mReportNextDraw) {
                boolean focusChangedDueToTouchMode = ensureTouchModeLocally(
                        (relayoutResult&WindowManagerGlobal.RELAYOUT_RES_IN_TOUCH_MODE) != 0);             // updatedConfiguration 第一次进入时设置为true，可以进入
                if (focusChangedDueToTouchMode || mWidth != host.getMeasuredWidth()
                        || mHeight != host.getMeasuredHeight() || dispatchApplyInsets ||
                        updatedConfiguration) {
                    ...
                     //第二次测量尺寸，这次是真正的测量， mDecorView 测量所有子View
                    performMeasure(childWidthMeasureSpec, childHeightMeasureSpec);

                   ....
                    layoutRequested = true;
                }
            }
        }
        ... 
          
        //2. 视图树的布局过程 调用 DecorView的 performLayout 对View树进行布局，
        //这一步可以得到View真正的位置和大小
          
        // didLayout= true ，所以 triggerGlobalLayoutListener = true
        final boolean didLayout = layoutRequested && (!mStopped || mReportNextDraw);          
        boolean triggerGlobalLayoutListener = didLayout
                || mAttachInfo.mRecomputeGlobalAttributes;
        if (didLayout) {
           //调用子View的layout方法进行布局，布局完成后就能确定尺寸和位置了
            performLayout(lp, mWidth, mHeight);
					...
        }

       ...
        if (triggerGlobalLayoutListener) {
            mAttachInfo.mRecomputeGlobalAttributes = false;
          // 整个布局树已经完成，触发回调，这也是为什么这个回调会被推荐用来获取控件的大小
          // 因为用post的方法，在onResume中取，会在下一个消息序列获取宽和高
          // 而使用回调可以在同一个消息队列中获得宽和高
            mAttachInfo.mTreeObserver.dispatchOnGlobalLayout();
        }
			 ...
         //3. 绘制过程 调用DecorView的performDraw()方法对View进行绘制
         
         // isViewVisible若 = false 则不绘制
        boolean cancelDraw = mAttachInfo.mTreeObserver.dispatchOnPreDraw() || !isViewVisible;

        if (!cancelDraw) {
            if (mPendingTransitions != null && mPendingTransitions.size() > 0) {
                for (int i = 0; i < mPendingTransitions.size(); ++i) {
                    mPendingTransitions.get(i).startChangingAnimations();
                }
                mPendingTransitions.clear();
            }
					// 大多数情况下都会走入 performDraw，API 29之前
          // 要判断SurfaceView是否是新创建的，
          // 若是新创建的，则在第二次调用performTraversals时才能调用performDraw
          
          // 绘制过程不是直接调用DecorView的方法，重点是根据是否使用硬件加速来确定使用硬件绘制还是软件绘制
            performDraw();
        } else {
          // 若因为某些原因没能成功执行 performDraw() 
          // 测量，布局流程也不会重新执行一遍，只重新执行绘制 performMeasrue() ，performLayout()
          // 因为若是测量过 mLayoutRequested = true ，不会重新走测量/逻辑
            if (isViewVisible) {
                // Try again
                scheduleTraversals();
            } else if (mPendingTransitions != null && mPendingTransitions.size() > 0) {
               ...
            }
        }

        if (mAttachInfo.mContentCaptureEvents != null) {
            notifyContentCatpureEvents();
        }

        mIsInTraversal = false;          
      
    }
    private boolean measureHierarchy(final View host, final WindowManager.LayoutParams lp,
            final Resources res, final int desiredWindowWidth, final int desiredWindowHeight) {
      ...
      // 是否是一次成功的测量，默认false
        boolean goodMeasure = false;
        if (lp.width == ViewGroup.LayoutParams.WRAP_CONTENT) {
          ...
        }
     
        if (!goodMeasure) {
          // 传入布局，也就是window的宽高和布局参数传进去，也就是View中 onMeasure方法需要的
            childWidthMeasureSpec = getRootMeasureSpec(desiredWindowWidth, lp.width);
            childHeightMeasureSpec = getRootMeasureSpec(desiredWindowHeight, lp.height);
          // 第一次：测量大小，其实是测量window的大小，开始测量
            performMeasure(childWidthMeasureSpec, childHeightMeasureSpec);
            ..
        }
        ...
    }
    // 开始测量  
    private void performMeasure(int childWidthMeasureSpec, int childHeightMeasureSpec) {
        ...
        try {
          // mView 也就是DecorView，执行measure方法，接下来一层一层的子View也会进行遍历，完成测量
            mView.measure(childWidthMeasureSpec, childHeightMeasureSpec);
        } finally {
            Trace.traceEnd(Trace.TRACE_TAG_VIEW);
        }
    }      
    // 获得测量参数  
    private static int getRootMeasureSpec(int windowSize, int rootDimension) {
        int measureSpec;
        switch (rootDimension) {
        case ViewGroup.LayoutParams.MATCH_PARENT:
            // Window can't resize. Force root view to be windowSize.
            measureSpec = MeasureSpec.makeMeasureSpec(windowSize, MeasureSpec.EXACTLY);
          ...
        return measureSpec;
    }      
    // 布局过程
    private void performLayout(WindowManager.LayoutParams lp, int desiredWindowWidth,
            int desiredWindowHeight) {
      ...
        final View host = mView;
        ... // 调用 decorView和所有子View的 layout 进行布局
            host.layout(0, 0, host.getMeasuredWidth(), host.getMeasuredHeight());
           ...
    } 
    // 绘制过程
   private void performDraw() {
       
        if (!dirty.isEmpty() || mIsAnimating || accessibilityFocusDirty) {
          // 根据是否使用硬件加速来确定使用硬件绘制还是软件绘制
            if (mAttachInfo.mThreadedRenderer != null && mAttachInfo.mThreadedRenderer.isEnabled()) {
              ...
                // 硬件绘制 draw() 方法
                mAttachInfo.mThreadedRenderer.draw(mView, mAttachInfo, this);
            } else {
             ...
								// 软件绘制 draw() 方法
                if (!drawSoftware(surface, mAttachInfo, xOffset, yOffset,
                        scalingRequired, dirty, surfaceInsets)) {
                    return false;
                }
            }
        }
        ...
    }
    private boolean drawSoftware(Surface surface, AttachInfo attachInfo, int xoff, int yoff,
            boolean scalingRequired, Rect dirty, Rect surfaceInsets) {
            ...
						// 软件绘制
            mView.draw(canvas);
           ...
        return true;
    }      
      
}    
```

## View.class

```java

@UiThread
public class View implements Drawable.Callback, KeyEvent.Callback,
        AccessibilityEventSource {	
    
    @UnsupportedAppUsage(maxTargetSdk = Build.VERSION_CODES.P)
    AttachInfo mAttachInfo;  
    final Handler mHandler;          
    // 设置View的Parent      
		void assignParent(ViewParent parent) {
		  
    		if (mParent == null) {
   		     mParent = parent;
    		} ..
    }
          
	
		// 建立View和Window之间的依赖
    @UnsupportedAppUsage(maxTargetSdk = Build.VERSION_CODES.P)
    void dispatchAttachedToWindow(AttachInfo info, int visibility) {
      // AttachInfo是ViewRootImpl传入的，我们可以用 mAttachInfo有没有值来判断View是否依附于Window
        mAttachInfo = info;
				...
    }
    // 系统自带方法也是用 mAttachInfo有没有值来判断View是否依附于Window
    public boolean isAttachedToWindow() {
        return mAttachInfo != null;
    }
    // 切换线程需要借助handler，handler是随着AttachInfo传来的
    public boolean post(Runnable action) {
        final AttachInfo attachInfo = mAttachInfo;
        // 有时发生崩溃了，但是View仍然被创建出来了，Handler就是空的，此时post不会立刻发送Runnable
        if (attachInfo != null) {
            return attachInfo.mHandler.post(action);
        }

        // 若发生崩溃，attachInfo = null ，先把Runnable存到一个队列当中
        getRunQueue().post(action);
        return true;
    }
    // mHandler是创建AttachInfo对象时构造函数传来的，而AttachInfo对象是ViewRootImpl构造函数中创建的
          
    AttachInfo(IWindowSession session, IWindow window, Display display,
                ViewRootImpl viewRootImpl, Handler handler, Callbacks effectPlayer,
                Context context) {
            ...
            mViewRootImpl = viewRootImpl;
            mHandler = handler;
            ...
        }  
    // 表示正在布局中，防止重复布局的措施      
    @CallSuper
    public void requestLayout() {
       ...
         // 表示正在布局的flag，在layout中才会消除掉
        mPrivateFlags |= PFLAG_FORCE_LAYOUT;
     ...
    }
    // 根据flag确定View是否处于布局过程中      
    public boolean isLayoutRequested() {
        return (mPrivateFlags & PFLAG_FORCE_LAYOUT) == PFLAG_FORCE_LAYOUT;
    }          
    public void layout(int l, int t, int r, int b) {
     ....
			// 重置标志位
        mPrivateFlags &= ~PFLAG_FORCE_LAYOUT;
      // 判断是否已经在布局中，若正在布局中，则不会往上层调用 requestLayout()
        if (mParent != null && !mParent.isLayoutRequested()) {
            mParent.requestLayout();
        }      
    }          
}
```

## WindowManagerImpl，WindowManager，WIndowManagerGlobal

每个Acitivty 都有一个WIndowManager对象，一个程序可能有很多歌WIndowManagerImpl，不同Manager都会把操作转交给WindowManagerGlobal，这样以后想做统一操作在Global中操作非常简单

### WindowManagerGlobal

记录所有的View和ViewRootImpl 这个类是隐藏的，可以返回得到

Activity在生命周期中能拿到Global，而Dialog没有生命周期，只能用反射拿到所有底层View和所有属性

```java
public final class WindowManagerGlobal {
  
  	// 记录所有的View和ViewRootImpl，布局参数
    @UnsupportedAppUsage
    private final ArrayList<View> mViews = new ArrayList<View>();
    @UnsupportedAppUsage
    private final ArrayList<ViewRootImpl> mRoots = new ArrayList<ViewRootImpl>();    
    @UnsupportedAppUsage
    private final ArrayList<WindowManager.LayoutParams> mParams =
            new ArrayList<WindowManager.LayoutParams>();		
  
    // 初始化   ViewRootImpl
    public void addView(View view, ViewGroup.LayoutParams params,
            Display display, Window parentWindow, int userId) {
      ViewRootImpl root;
       // 初始化   ViewRootImpl
        root = new ViewRootImpl(view.getContext(), display);	
      ...
       // 每次创建后都会存储View，ViewRootImpl和各种参数
        mViews.add(view);
        mRoots.add(root);
      // 和Windows的布局参数是统一的
        mParams.add(wparams);
      
      // 关键 调用 ViewRootImpl的setView方法
      root.setView(view, wparams, panelParentView, userId);
    }  

}
```

### WindowManagerImpl

```java
@Override
    public void addView(@NonNull View view, @NonNull ViewGroup.LayoutParams params) {
        applyDefaultToken(params);
        mGlobal.addView(view, params, mContext.getDisplayNoVerify(), mParentWindow,
                mContext.getUserId());
    }
```



#### WindowManager

Activity 的成员变量，是一个接口继承了ViewManager，实际上使用的实例是WindowManagerImpl

```java
@SystemService(Context.WINDOW_SERVICE)
public interface WindowManager extends ViewManager {
  	....
}
```

#### ViewManager

只是一个接口 ActivityThread 中 有使用

```java
public interface ViewManager
{  
    public void addView(View view, ViewGroup.LayoutParams params);
    public void updateViewLayout(View view, ViewGroup.LayoutParams params);
    public void removeView(View view);
}
```

```java
public final class WindowManagerImpl implements WindowManager {
  // global是个单例对象
	 private final WindowManagerGlobal mGlobal = WindowManagerGlobal.getInstance();
  
 		 @Override
    public void addView(@NonNull View view, @NonNull ViewGroup.LayoutParams params) {
        applyDefaultToken(params);
       //add View 丢该global去做
        mGlobal.addView(view, params, mContext.getDisplayNoVerify(), mParentWindow,
                mContext.getUserId());
    }

}
```



## 在子线程中更新 UI 不报错的几种方式

子线程更新UI不一定会报错

```kotlin
requestWindowFeature(Window.FEATURE_NO_TITLE)
setContentView(R.layout.activity_main)

text = findViewById(R.id.text)
// 直接在子线程更新ui 不会崩溃
thread {
    text.text = "ok!"
}

text.setOnClickListener(object: View.OnClickListener {
    override fun onClick(v: View?) {
        println(window.decorView.parent.toString())
        // 子线程更新 ui 会崩溃
        thread {
            text.text = "onCreate!"
        }
    }
})
```

报错信息：

```sh
  Process: com.hencoder.customviewdrawing, PID: 23675
    android.view.ViewRootImpl$CalledFromWrongThreadException: Only the original thread that created a view hierarchy can touch its views.
        at android.view.ViewRootImpl.checkThread(ViewRootImpl.java:8825)
        at android.view.ViewRootImpl.requestLayout(ViewRootImpl.java:1535)
        at android.view.View.requestLayout(View.java:24661)
        at android.view.View.requestLayout(View.java:24661)
        at android.view.View.requestLayout(View.java:24661)
        at android.view.View.requestLayout(View.java:24661)
        at android.view.View.requestLayout(View.java:24661)
        at android.widget.TextView.checkForRelayout(TextView.java:9762)
        at android.widget.TextView.setText(TextView.java:6326)
        at android.widget.TextView.setText(TextView.java:6154)
        at android.widget.TextView.setText(TextView.java:6106)
        at com.hencoder.customviewdrawing.MainActivity$onCreate$2$onClick$1.invoke(MainActivity.kt:31)
        at com.hencoder.customviewdrawing.MainActivity$onCreate$2$onClick$1.invoke(MainActivity.kt:26)
        at kotlin.concurrent.ThreadsKt$thread$thread$1.run(Thread.kt:30)
```

对应报错的位置则是View.requestLayout() 中一致调用到ViewRootImpl.requestLayout()

而ViewRootImpl是decorView的parentView

```java
 @CallSuper
    public void requestLayout() {
        if (mMeasureCache != null) mMeasureCache.clear();

        if (mAttachInfo != null && mAttachInfo.mViewRequestingLayout == null) {
            // Only trigger request-during-layout logic if this is the view requesting it,
            // not the views in its parent hierarchy
            ViewRootImpl viewRoot = getViewRootImpl();
            if (viewRoot != null && viewRoot.isInLayout()) {
                if (!viewRoot.requestLayoutDuringLayout(this)) {
                    return;
                }
            }
            mAttachInfo.mViewRequestingLayout = this;
        }

        mPrivateFlags |= PFLAG_FORCE_LAYOUT;
        mPrivateFlags |= PFLAG_INVALIDATED;
				// 若parent == null 根本不会调用  ViewRootImp.requestLayout()
        //  更不会调用  ViewRootImpl.checkThread();
        if (mParent != null && !mParent.isLayoutRequested()) {
            mParent.requestLayout();
        }
        if (mAttachInfo != null && mAttachInfo.mViewRequestingLayout == this) {
            mAttachInfo.mViewRequestingLayout = null;
        }
    }
```

### 为什么子线程更新UI会报错？

ViewRootImpl成为控件树最顶层DecorView的Parent时，这样才有可能更新UI的时候触发他的requestLayout(),

只有触发了requestLayout()才会调用它的检查线程方法checkThread()

### 1.主线程申请成功后子线程申请

利用View 防止重复绘制的优化，先进行一次requestLayout()，第二次就会被忽略

若调用View 触发requestLayout()，会让整条View链的所有View 设置一个Flag：` mPrivateFlags |= PFLAG_FORCE_LAYOUT;`,表示正在布局，在layout的时候才会把它消除掉，

再次调用View的requestLayout()时，View会根据标志位判断，若标志位表示正在布局，则代表已经申请过requestLayout(），View不会再调用上层父布局的requestLayout()，这样就不会触发ViewRootImpl的线程检查

类似的，TextView里面

现在主线程调用setText，会触发 reqeustLayout()

子线程调用setText时，相当于连续触发reqeustLayout()

```java
    @UnsupportedAppUsage
    private void setText(CharSequence text, BufferType type,
                         boolean notifyBefore, int oldlen) {
      ...
         setTextInternal(text);// 已经设置好文字了
        if (mLayout != null) {
          // mLayout 不为空，会触发requestLayout()
            checkForRelayout();
        }   ....         
    }
    @UnsupportedAppUsage
    private void checkForRelayout() {
      ....  requestLayout(); ...
    }
```

Eg:

```kotlin
val textview = findViewById<TextView>(R.id.textview)

textview.setOnClickLitener {
  textView.text = "Main" // 或者    it.requestLayout()
  tread {
    textview.text = "${Thread.currentThread().name}"
  }
}
```

​	 						 			 			 			 		

### **2.** 在子线程中创建 ViewRootImpl

ViewRootImpl检查线程

```java
   public ViewRootImpl(Context context, Display display, IWindowSession session,
            boolean useSfChoreographer) {  
    
   ... mThread = Thread.currentThread(); ...
   }
  void checkThread() {
      // 检查线程使用的mThread 对象
        if (mThread != Thread.currentThread()) {
        ...
        }
    }
```

mThread对象是初始化时构建的，创建ViewRootImpl时所在的线程就是mThread所在的线程
ViewRootImpl是WindowManagerGlobal 调用addView()时创建的
由于WindowMangaerGlobal是隐藏类，我们可以通过WindowManager来做这件事 

```kotlin
 thread {
   // ViewRootImpl 需要一个Handler（ ViewRootHandler），而Handler需要Looper，子线程没有Looper
   Looper.prepare()
   // 在子线程中创建一个View
   val button = Button(this)
   // 让它在子线程中创建一个ViewRootImpl，它最终会调用WindowManagerGlobal.addView()
   windowManager.addView(button,WinowManager.LayoutParams())
   button.setOnClickLitener {
     buttun.text = "${Thread.currentThread().name} : ${SystemClock.uptimeMillis()}"
   }
   // 只有Handler和Looper ，handler无法正常处理任务，还需要让Looper轮训起来
   Looper.loop()
 }
```

#### 子线程弹Toast

报错不同，但是同样可以通过代码前后增加`   Looper.prepare()`,`    Looper.loop()`解决

![image-20210916223001494](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210916223001494.png)

### 3. 利用硬件加速机制绕开 requestLayout()

在硬件加速的支持下，如果控件只是经常了 invalidate() ，而没有触发requestLayout() 是不会触发。ViewRootImplcheckThread() 的。

子View会依赖父ViewGroup的invalidate()实现，而作为最顶层的ViewRootImpl，它的invalidate()方法会直接调用scheduleTraversals();绘制图形，而不像requestLayout() 在调用scheduleTraversals()之前要chekThread()

TextView.setView()会调用  checkForRelayout() 方法，宽度不变或者宽高都不变则只会调用invalidate();

```java
    @UnsupportedAppUsage
    private void setText(CharSequence text, BufferType type,
                         boolean notifyBefore, int oldlen) {
       checkForRelayout() 
    }    

		@UnsupportedAppUsage
    private void checkForRelayout() {
      // 判断宽度是不是固定/不变的
        if ((mLayoutParams.width != LayoutParams.WRAP_CONTENT
                || (mMaxWidthMode == mMinWidthMode && mMaxWidth == mMinWidth))
                && (mHint == null || mHintLayout != null)
                && (mRight - mLeft - getCompoundPaddingLeft() - getCompoundPaddingRight() > 0)) {
          ...
            makeNewLayout(want, hintWant, UNKNOWN_BORING, UNKNOWN_BORING,
                          mRight - mLeft - getCompoundPaddingLeft() - getCompoundPaddingRight(), false);

            if (mEllipsize != TextUtils.TruncateAt.MARQUEE) {
                // In a fixed-height view, so use our new text layout.
                if (mLayoutParams.height != LayoutParams.WRAP_CONTENT
                        && mLayoutParams.height != LayoutParams.MATCH_PARENT) {
                    autoSizeText();
                    invalidate();
                    return;
                }

               // 高度是不是和以前一样/固定的
                if (mLayout.getHeight() == oldht
                        && (mHintLayout == null || mHintLayout.getHeight() == oldht)) {
                    autoSizeText();
                  // 只调用invalidate()
                    invalidate();
                    return;
                }
            }

            // 同时调用  invalidate 和 requestLayout
            requestLayout();
            invalidate();
        } 。。。
    }
    public void invalidate() {
        invalidate(true);
    }

    @UnsupportedAppUsage
    public void invalidate(boolean invalidateCache) {
        invalidateInternal(0, 0, mRight - mLeft, mBottom - mTop, invalidateCache, true);
    }
	// 的最终调用
    void invalidateInternal(int l, int t, int r, int b, boolean invalidateCache,
          
      ...
            final ViewParent p = mParent;
           ...
                // 父ViewGroup的  invalidateChild ，传入自身          
                p.invalidateChild(this, damage);
           ...
        
    }

```

ViewGroup

```java
    public final void invalidateChild(View child, final Rect dirty) {
        final AttachInfo attachInfo = mAttachInfo;
        if (attachInfo != null && attachInfo.mHardwareAccelerated) {
            // 如果是硬件加速，则进入硬件加速捷径
            onDescendantInvalidated(child, child);
            return;
        }

        ...
    }

    @Override
    @CallSuper
    public void onDescendantInvalidated(@NonNull View child, @NonNull View target) {
       
       //一致调用它的parent的方法，最顶层为ViewRootImpl
        if (mParent != null) {
            mParent.onDescendantInvalidated(this, target);
        }
    }
```

ViewRootImpl

```java
    @Override
    public void onDescendantInvalidated(@NonNull View child, @NonNull View descendant) {
        ...
         // 直接调用了 invalidate
        invalidate();
    }

    @UnsupportedAppUsage
    void invalidate() {
        mDirty.set(0, 0, mWidth, mHeight);
        if (!mWillDrawSoon) {
          // 直接绘制
            scheduleTraversals();
        }
    }
  @Override
    public void requestLayout() {
      //mHandlingLayoutInLayoutRequest 标志位表示是否正在布局
        if (!mHandlingLayoutInLayoutRequest) {
            // 检查线程
            checkThread();
            mLayoutRequested = true;
            // 绘制
            scheduleTraversals();
        }
    }
```



### 4.SurfaceView

Android 中有一个控件 SurfaceView ，它可以通过 holder 获得 Canvas 对象， 可以直接在子线程中更新 UI。

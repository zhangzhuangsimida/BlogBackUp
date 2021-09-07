---
title: '自定义view布局01:布局流程完全解析'
date: 2021-09-06 17:53:02
categories:
- Android
- 自定义view
tags:
- Android
- 自定义view
---

# 布局流程完全解析

## 布局过程

确定每个 View 的位置和尺寸 

作用: 为**绘制**和**触摸范围**做支持

- **绘制**: 知道往哪里绘制
- **触摸反馈**: 知道用户点的是哪里

## 流程

### 从整体看

- 测量流程:从根 View 递归调用每一级子 View 的 measure() 方法，对它们进行测量
- 布局流程:从根 View 递归调用每一级子 View 的 layout() 方法，把测量过程得 出的子 View 的位置和尺寸传给子 View，子 View 保存

View onLayout是空方法

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907111935951.png" alt="image-20210907111935951" style="zoom: 67%;" />

View Group需要处理子View的布局

![image-20210907112056602](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907112056602.png)

#### 为什么要分两个流程?

因为可能会重复测量

测量是一个动态的过程我们要测量多个子View ，有些子View可能要测量多次

比如下面的例子第一个子View是 match_parent ，第一次测量是没有结果的，需要两次测量，把测量/布局分成两个流程，可以让布局只使用最后保存的生效的数值，提高效率

![image-20210906175625735](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210906175625735.png)

### 从个体看对于每个View

1. 运行前，开发者在 xml 文件里写入对 View 的布局要求 layout_xxx

2. 父 View 在自己的 onMeasure() 中，根据开发者在 xml 中写的对子 View 的要 求，和自己的可用空间，得出对子 View 的具体尺寸要求（结合上一步开发者写入的 layout_xxx和父View的可用空间计算）

	![image-20210907110500303](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907110500303.png)

3. 子 View 在自己的 onMeasure() 中，根据父 View 的要求和自己的特性算出自己 的期望尺寸
   - 如果是 ViewGroup，还会在这里调用每个子 View 的 measure() 进行测量
4. 父 View 在子 View 计算出期望尺寸后，得出子 View 的实际尺寸和位置

6. 子 View 在自己的 layout() 方法中，将父 View 传进来的自己的实际尺寸和位置 保存
   - 如果是 ViewGroup，还会在 onLayout() 里调用每个子 View 的 layout() 把 它们的尺寸位置传给它们



## 自定义布局



具体实现方式：

- 继承已有View，简单修改它们的尺寸：重写 onMeasure()
  - SquareImageView 方形view
- 对自定义View完全进行自定义运算：重写onMeasure()
  - CircleView 圆形view，外部根据内部图形设定宽高
- 自定义Layout：重写omMeasure()和onLayout()
  - TagLayout 标签布局（Android的flex-box 类似）

### 自定义View

#### 自定义View方式一：简单改写已有View的尺寸

1. 重写onMeasure()

2. 用getMeasuredWidth()和getMeasuredHeight()获取到测量出的尺寸

3. 计算出最终要的尺寸

4. 用setOnMeasuredDimension(width, height)把结果保存

```kotlin
class SquareImageView(context: Context?, attrs: AttributeSet?) : AppCompatImageView(context, attrs) {

  override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
    super.onMeasure(widthMeasureSpec, heightMeasureSpec)
		// 使用系统计算过的宽&高，计算比较小的那个
    val size = min(measuredWidth, measuredHeight)
    // 存储宽高，并非作为返回值给父类，而是使用时自己或父类去拿
    setMeasuredDimension(size, size)
  }
}
```



#### 重写layout也能改写尺寸，为什么要重写onMeaSure

若直接重写layout的确能改写尺寸，但是父View是不知道你的改动的，会造成位置错误

Eg

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <com.hencoder.layoutsize.view.SquareImageView
        android:layout_width="300dp"
        android:layout_height="200dp"
        android:src="@drawable/avatar_rengwuxian"
         />
    <View
        android:layout_width="200dp"
        android:layout_height="200dp"
        android:background="@color/purple_200"/>
</LinearLayout>
```

对于Android系统你的布局应该是这样的

![image-20210907085754293](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907085754293.png)

若在layout中修改了尺寸，但系统不知道你的修改，结果就是：

```kotlin
class SquareImageView(context: Context?, attrs: AttributeSet?) : AppCompatImageView(context, attrs) {
  override fun layout(l: Int, t: Int, r: Int, b: Int) {
    val width = r - l
    val height = b - t
    val size = min(width,height)
    super.layout(l, t, l+size, t+size)
  }
}  
```

![image-20210907085940819](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907085940819.png)

#### 测量尺寸的方法

```kotlin
getMeasuredHeight() // 测量期望尺寸 高
getMeasuredWidth()  // 测量期望尺寸 宽
getHeight() // 测量实际尺寸 高
getWidth() // 测量实际尺寸 宽

  //  View.class 中  getWidth() ，getHeight() 能获得View实际应用的值
 
  @ViewDebug.ExportedProperty(category = "layout")
    public final int getWidth() {
        return mRight - mLeft;
    }

   
    @ViewDebug.ExportedProperty(category = "layout")
    public final int getHeight() {
        return mBottom - mTop;
    }
```

- getMeasuredHeight/Width方法获得的是期望的值，可能会被父类修改未必准确，测量过程中能拿到
- getHeight/Width方法获得的是布局实际应用的宽高，但是在测量过程中拿不到

> 有时用getHeight/Width 获得了宽高值，此时View却进行了刷新导致宽高变化，获得的值还是上一轮的
>
> 而每次刷新getMeasuredHeight/Width会重新计算，虽然不一定是最后应用的但更实时
>
> **所以测量过程中我们有时只能使用getMeasuredHeight/Width ()，其他时候使用getHeight/Width**

#### 自定义View方式二：完全自定义View的尺寸

1. 重写onMeasure()

2. 计算出自己的尺寸

3. 用resolveSize() / resolveSizeAndState() 修正结果
4. 使用setMeasuredDimension(width,height) 保存结果

不重写onMeasure()

```kotlin
// 半径
private val RADIUS = 100.dp
private val PADDING = 100.dp

class CircleView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {
  @RequiresApi(Build.VERSION_CODES.M)
  private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
    color = getContext().getColor(R.color.purple_200)
  }

  @RequiresApi(Build.VERSION_CODES.M)
  override fun onDraw(canvas: Canvas) {
    super.onDraw(canvas)

    canvas.drawCircle(PADDING + RADIUS, PADDING + RADIUS, RADIUS, paint)
  }
}
```

Xml:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <com.hencoder.layoutsize.view.CircleView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/avatar_rengwuxian"
        android:background="@color/teal_200"
         />

</LinearLayout>
```

View 默认会填充整个屏幕

![image-20210907101823266](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907101823266.png)

重写onMeasure方法指定定View的尺寸

```kotlin
override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
  // 重写View的宽高
  val size = ((PADDING + RADIUS) * 2).toInt()
  // 考虑父View的宽高建议 ： widthMeasureSpec: Int, heightMeasureSpec: Int
  val width = resolveSize(size, widthMeasureSpec)
  val height = resolveSize(size, heightMeasureSpec)
  setMeasuredDimension(width, height)
}
```

Xml ：View不会再填充整个屏幕：



![image-20210907102042312](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907102042312.png)

#### 父View的宽高建议

 onMeasure方法的两个参数 widthMeasureSpec，heightMeasureSpec是父View的宽高建议

有三种模式：

1. 不超过指定宽高 MeasureSpec.AT_MOST
2. 精确指定宽高 MeasureSpec.EXACTLY
3. 不限制 MeasureSpec.UNSPECIFIED

```kotlin

  override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
    val size = ((PADDING + RADIUS) * 2).toInt()
    // 获得限制宽/高的模式 ：MeasureSpec.getMode
    val specWidthMode = MeasureSpec.getMode(widthMeasureSpec)
    // 若模式是不限制，就可以无视了，若有限制，需要获得精确的值/限制的值，通过getSize拿到
    val specWidthSize = MeasureSpec.getSize(widthMeasureSpec)
    var width = 0
    if (MeasureSpec.EXACTLY == specWidthMode){
      // 精确模式
      width = specWidthSize
    }else if (MeasureSpec.AT_MOST == specWidthMode){
      // 最大值限制
      width = if (size > widthMeasureSpec) widthMeasureSpec else size

    }else if (MeasureSpec.UNSPECIFIED == specWidthMode) {
      //无限制
      width = size
    }
    setMeasuredDimension(width, size)
  }
```

####  resolveSize和resolveSizeAndState和

父View的宽高限制/建议都是固定逻辑，系统已经有方法处理这套逻辑了

resolveSize：

```kotlin
val width = resolveSize(size, widthMeasureSpec)
val height = resolveSize(size, heightMeasureSpec)
```

resolveSizeAndState和resolveSize的区别在于，当测量模式是AT_MOST进行最大值限制的时候，若测量的值超出了最大值限制，会上报给父view一个MEASURED_STATE_TOO_SMALL的值表达空间不足，然而在实际应用中一般不会去读这个值，所以一遍都用resovleSize()方法处理

```kotlin
public static int resolveSizeAndState(int size, int measureSpec, int childMeasuredState) {
    final int specMode = MeasureSpec.getMode(measureSpec);
    final int specSize = MeasureSpec.getSize(measureSpec);
    final int result;
    switch (specMode) {
        case MeasureSpec.AT_MOST:
            if (specSize < size) {
                result = specSize | MEASURED_STATE_TOO_SMALL;
            } else {
                result = size;
            }
            break;
        case MeasureSpec.EXACTLY:
            result = specSize;
            break;
        case MeasureSpec.UNSPECIFIED:
        default:
            result = size;
    }
    return result | (childMeasuredState & MEASURED_STATE_MASK);
}
```

### 自定义Layout(ViewGroup)

- 重写 onMeasure()
  - 遍历每个子 View，测量子 View
    - 测量完成后，得出子 View 的实际位置和尺寸，并暂时保存
    - 有些子 View 可能需要重新测量
  -  测量出所有子 View 的位置和尺寸后，计算出自己的尺寸，并用 setMeasuredDimension(width, height) 保存
- 重写 onLayout()
  - 遍历每个子 View，调用它们的 layout() 方法来将位置和尺寸传给它们

Eg：

```kotlin
class TagLayout(context: Context?, attrs: AttributeSet?) : ViewGroup(context, attrs) {
  // 存储每个子View的尺寸位置
  private val childrenBounds = mutableListOf<Rect>()
  // 重写 onMeasure()
  override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
    // 记录已用的宽度
    var widthUsed = 0
    // 记录已用高度
    var heightUsed = 0
    // 单行 已用 宽度
    var lineWidthUsed = 0
    // 单行最大高度
    var lineMaxHeight = 0
    // 获得父类限制的宽度
    val specWidthSize = MeasureSpec.getSize(widthMeasureSpec)
    // 获得父类的尺寸限制模式 ，有三种 UNSPECIFIED无限制 ，EXACTLY精确，AT_MOST不能超过限制的最大值
    val specWidthMode = MeasureSpec.getMode(widthMeasureSpec)
    //1. 遍历每个子 View，测量子 View
    for ((index, child) in children.withIndex()) {
      // 调用 子View的 mseasure方法测量View的尺寸和位置
      // 需要传递宽高限制 widthMeasureSpec，heightMeasureSpec，已经用的宽度/高度
      // 这个通用方法，原则上只要不超过父类的宽高可以随意设置
      measureChildWithMargins(child, widthMeasureSpec, 0, heightMeasureSpec, heightUsed)
      // 换行：父View的尺寸限制模式 不是无限制 且 已用宽度加上这个子View的测量宽度 超过父类限制的最大值
      if (specWidthMode != MeasureSpec.UNSPECIFIED &&
        lineWidthUsed + child.measuredWidth > specWidthSize) {
        // 换行 行的最大高度/行的已有宽度都要归零
        lineWidthUsed = 0
        // 存储当前的行最大高度，得到已用高度
        heightUsed += lineMaxHeight
        lineMaxHeight = 0
        // 给子View测量位置/尺寸
        measureChildWithMargins(child, widthMeasureSpec, 0, heightMeasureSpec, heightUsed)
      }
      // 2. 测量量完成后，得出子 View 的实际位置和尺寸，并暂时保存
      if (index >= childrenBounds.size) {
        childrenBounds.add(Rect())
      }
      // 拿到用于存储的Rect 对象
      val childBounds = childrenBounds[index]
      // 对Rect 对象修改，暂时存储具体的位置，尺寸
      childBounds.set(lineWidthUsed, heightUsed, lineWidthUsed + child.measuredWidth, heightUsed + child.measuredHeight)
      // 记录子view已用宽度
      lineWidthUsed += child.measuredWidth
      // 计算 当前行宽度是否超过已用宽度
      widthUsed = max(widthUsed, lineWidthUsed)
      // 计算当前子View的高度是否超过 之前其他行的最大高度
      lineMaxHeight = max(lineMaxHeight, child.measuredHeight)
    }
    // 算出自己的尺寸 宽度，高度
    // 宽度就是已用宽度度
    val selfWidth = widthUsed
    // 高度使用已用高度+本行最大行高（只有换行时存储上一行的行高到 heightUsed，所以这里要+本行行高）
    val selfHeight = heightUsed + lineMaxHeight
    // 应用计算出来的自身尺寸
    setMeasuredDimension(selfWidth, selfHeight)
  }
  // 重写 onLayout()
  override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
    //3. 遍历每个子 View，调用它们的 layout() 方法来将位置和尺寸传给它们
    for ((index, child) in children.withIndex()) {
      // 取出存储的每个子View的尺寸，位置信息
      val childBounds = childrenBounds[index]
      // 调用子View的layout ()  传递存储的信息
      child.layout(childBounds.left, childBounds.top, childBounds.right, childBounds.bottom)
    }
  }

  override fun generateLayoutParams(attrs: AttributeSet?): LayoutParams {
    return MarginLayoutParams(context, attrs)
  }
}
```

效果：

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210907163741810.png" alt="image-20210907163741810" style="zoom:67%;" />

#### measureChildWithMargins

ViewGroup设置子VIew的尺寸/位置

```java
 protected void measureChildWithMargins(View child,
            int parentWidthMeasureSpec, int widthUsed,
            int parentHeightMeasureSpec, int heightUsed) {
   //  child： 具体设置的子View对象
   //  parentWidthMeasureSpec ：父View的宽
   //  widthUsed： 已用宽度
   //  parentHeightMeasureSpec： 父View的高
   //  heightUsed： 已用高度
        final MarginLayoutParams lp = (MarginLayoutParams) child.getLayoutParams();

        final int childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec,
                mPaddingLeft + mPaddingRight + lp.leftMargin + lp.rightMargin
                        + widthUsed, lp.width);
        final int childHeightMeasureSpec = getChildMeasureSpec(parentHeightMeasureSpec,
                mPaddingTop + mPaddingBottom + lp.topMargin + lp.bottomMargin
                        + heightUsed, lp.height);

        child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
    }

```

#### getChildMeasureSpec 

根据父View的尺寸/限制模式，padding等信息获得子View尺寸

```java
public static int getChildMeasureSpec(int spec, int padding, int childDimension) {
    int specMode = MeasureSpec.getMode(spec);
    int specSize = MeasureSpec.getSize(spec);

    int size = Math.max(0, specSize - padding);

    int resultSize = 0;
    int resultMode = 0;

    switch (specMode) {
    // Parent has imposed an exact size on us
    case MeasureSpec.EXACTLY:
        if (childDimension >= 0) {
            resultSize = childDimension;
            resultMode = MeasureSpec.EXACTLY;
        } else if (childDimension == LayoutParams.MATCH_PARENT) {
            // Child wants to be our size. So be it.
            resultSize = size;
            resultMode = MeasureSpec.EXACTLY;
        } else if (childDimension == LayoutParams.WRAP_CONTENT) {
            // Child wants to determine its own size. It can't be
            // bigger than us.
            resultSize = size;
            resultMode = MeasureSpec.AT_MOST;
        }
        break;

    // Parent has imposed a maximum size on us
    case MeasureSpec.AT_MOST:
        if (childDimension >= 0) {
            // Child wants a specific size... so be it
            resultSize = childDimension;
            resultMode = MeasureSpec.EXACTLY;
        } else if (childDimension == LayoutParams.MATCH_PARENT) {
            // Child wants to be our size, but our size is not fixed.
            // Constrain child to not be bigger than us.
            resultSize = size;
            resultMode = MeasureSpec.AT_MOST;
        } else if (childDimension == LayoutParams.WRAP_CONTENT) {
            // Child wants to determine its own size. It can't be
            // bigger than us.
            resultSize = size;
            resultMode = MeasureSpec.AT_MOST;
        }
        break;

    // Parent asked to see how big we want to be
    case MeasureSpec.UNSPECIFIED:
        if (childDimension >= 0) {
            // Child wants a specific size... let him have it
            resultSize = childDimension;
            resultMode = MeasureSpec.EXACTLY;
        } else if (childDimension == LayoutParams.MATCH_PARENT) {
            // Child wants to be our size... find out how big it should
            // be
            resultSize = View.sUseZeroUnspecifiedMeasureSpec ? 0 : size;
            resultMode = MeasureSpec.UNSPECIFIED;
        } else if (childDimension == LayoutParams.WRAP_CONTENT) {
            // Child wants to determine its own size.... find out how
            // big it should be
            resultSize = View.sUseZeroUnspecifiedMeasureSpec ? 0 : size;
            resultMode = MeasureSpec.UNSPECIFIED;
        }
        break;
    }
    //noinspection ResourceType
    return MeasureSpec.makeMeasureSpec(resultSize, resultMode);
}
```

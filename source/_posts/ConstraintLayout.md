---
title: ConstraintLayout
date: 2022-03-08 14:50:07
categories:
- Android
tags:
- Android
---

# ConstraintLayout

## 布局

### 居中

#### 居中于⽗容器

```xml
app:layout_constraintStart_toStartOf="parent"

app:layout_constraintEnd_toEndOf="parent"

app:layout_constraintTop_toTopOf="parent"

app:layout_constraintBottom_toBottomOf="parent"
```

#### 居中于控件中⼼

##### ⽔平⽅向居中

```xml
app:layout_constraintStart_toStartOf="@id/view"

app:layout_constraintEnd_toEndOf="@id/view"
```



##### 垂直⽅向居中

```xml
app:layout_constraintTop_toTopOf="@id/view"

app:layout_constraintBottom_toBottomOf="@id/view"
```

##### 居中于控件的边

控件垂直居中于 view 的「下边」

```xml
 <ImageView
        android:id="@+id/img"
        android:layout_width="match_parent"
        android:layout_margin="32dp"
        android:scaleType="fitXY"
        app:layout_constraintEnd_toStartOf="parent"
        android:layout_marginTop="120dp"
        android:background="@color/colorPrimary"
        app:layout_constraintTop_toTopOf="parent"
        android:layout_height="300dp"/>

    <Button
        app:layout_constraintTop_toBottomOf="@+id/img"
        app:layout_constraintBottom_toBottomOf="@id/img"
        app:layout_constraintLeft_toLeftOf="@id/img"
        app:layout_constraintRight_toRightOf="@id/img"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
```

![image-20220309140530139](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20220309140530139.png)

> 中东地区从右向左阅读，用start，end 属性将不需要特意适配。

## 填充

### ⽔平⽅向填充⽗容器（通过 match_constraint ）

```xml
app:layout_constraintStart_toStartOf="parent"

app:layout_constraintEnd_toEndOf="parent"

android:layout_width="0dp"
```

> 备注：在早期版本中 match_parent 没有效果。

## 权重

为⽔平⽅向的控件设置权重，⼤⼩为 2:1:1 。

```xml
<!-- (view-1) -->

android:layout_width="0dp"

app:layout_constraintHorizontal_weight="2"

<!-- (view-2) -->

android:layout_width="0dp"

app:layout_constraintHorizontal_weight="1"

<!-- (view-3) -->

android:layout_width="0dp"

app:layout_constraintHorizontal_weight="1"
```

## ⽂字基准线对⻬

```xml
app:layout_constraintBaseline_toBaselineOf
```

## 圆形定位

通过「圆⼼」「⻆度」「半径」设置圆形定位

```xml
app:layout_constraintCircle="@id/view"

app:layout_constraintCircleAngle="90"

app:layout_constraintCircleRadius="180dp"
```

## 特殊属性

### 约束限制

限制控件⼤⼩不会超过约束范围。

```xml
app:layout_constrainedWidth="true"

app:layout_constrainedHeight="true
```

### 偏向

控制控件在垂直⽅向的 30%的位置

由于左右/上下两个方向都加约束，会让控件居中，加上bias 偏向可以避免居中，可用树脂为0.0  ~1.0

```xml
app:layout_constraintTop_toBottomOf="parent"

app:layout_constraintBottom_toBottomOf="parent"

app:layout_constraintVertical_bias="0.3"
```

除了配合百分⽐定位，还有⽤于配合有时在「约束限制(constrainedWidth/Height)」的条件下不需要居中效果的情况

### 垂直⽅向居顶部

```xml
app:layout_constraintTop_toBottomOf="parent"

app:layout_constraintBottom_toBottomOf="parent"

app:layout_constrainedHeight="true"

app:layout_constraintVertical_bias="0.0"
```

### layout_goneMargin

在约束的父控件visibility="gone" 的时候才生效的margin

```xml

    <TextView
        android:id="@+id/textview"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:background="@color/colorPrimary"
        android:text="长文本长文本"
        android:textColor="@android:color/white"
        android:textSize="28sp"
        android:visibility="gone"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />


    <ImageView
        app:layout_goneMarginStart="16dp"
        android:id="@+id/avatar"
        android:layout_width="40dp"
        android:layout_height="40dp"
        android:src="@mipmap/ic_launcher_round"
        app:layout_constraintStart_toEndOf="@id/textview"
        app:layout_constraintTop_toTopOf="@id/textview" />
```



## 约束链

在约束链上的**第⼀个控件**上加上 chainStyle ，⽤来改变⼀组控件的布局⽅式

- packed（打包) 常用,Eg： 让两个控件组合在一起居中
- spread （扩散 ）默认，不用写
- spread_inside（内部扩散） 很少用
- 垂直⽅向 packed

```xml
app:layout_constraintVertical_chainStyle="packed"
```



## 宽⾼⽐

有时候我们需要根据比例计算空间的大小，⾄少需要⼀个⽅向的值为 match_constraint ，也就是0dp

默认的都是「宽⾼⽐」，然后根据另外⼀条边和⽐例算出match_constraint 的值

### 已确定宽/高的值

x:y 默认表示的都是 width:height

宽是 0dp，⾼是 100dp，ratio 是 2:1

默认情况下是宽是 200dp，但是我们可以指定被约束的边是 height，那么宽度就是50 dp

⾼是 0dp，宽是 100 dp，ratio 是 2:1

默认情况下是⾼是 50 dp，但是我们指定被约束的边是 width，那么⾼度为200dp

Eg:

 ![image-20220309172928244](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20220309172928244.png)

```xml
  <ImageView
        android:layout_height="100dp"
        android:layout_width="0dp"
        app:layout_constraintDimensionRatio="2:1"
        android:background="@color/colorPrimaryDark"
        android:scaleType="fitXY"
        android:src="@mipmap/ic_launcher"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />
```

### 若宽高都是match_constraint （0dp）

若宽高都是match_constraint （0dp）则需要标注根据哪个边计算宽高

根据Width算：`app:layout_constraintDimensionRatio="W,2:1"`

根据Height算：`app:layout_constraintDimensionRatio="H,2:1"`

如果有固定的宽/高值（不是0dp），就不需要标记字母。

### 百分⽐布局

百分⽐布局需要对应⽅向上的值为 match_constraint

百分⽐是 parent 的百分⽐，⽽不是约束区域的百分⽐

Eg：宽度是⽗容器的 30%

```xml
android:layout_width="0dp"

app:layout_constraintWidth_percent="0.3"
```

>  约束布局的百分比布局一般用

## 辅助控件

### GuideLine 辅助线

设置辅助线的⽅向 `android:orientation="vertical / horizontal"`

设置辅助线的位置，根据⽅向不同

距离左侧或上侧的距离` layout_constraintGuide_begin = "xxdp"`

距离右侧或下侧的距离` layout_constraintGuide_end = "xxdp"`

百分⽐` layout_constraintGuide_percent ="0.2"`,值可以是负数，也可以超过1

Eg:

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.constraintlayout.widget.Guideline
        android:id="@+id/guideline"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        app:layout_constraintGuide_begin="120dp"
        app:layout_constraintGuide_end="60dp"  />

    <TextView
        android:id="@+id/tv_username"
        android:layout_width="wrap_content"
        android:layout_height="60dp"
        android:layout_marginTop="72dp"
        android:gravity="center_vertical"
        android:text="用户名"
        app:layout_constraintEnd_toStartOf="@+id/guideline"
        app:layout_constraintTop_toTopOf="parent" />

    <TextView
        android:id="@+id/tv_password"
        android:layout_width="wrap_content"
        android:layout_height="60dp"
        android:gravity="center_vertical"
        android:text="密码"
        app:layout_constraintEnd_toStartOf="@+id/guideline"
        app:layout_constraintTop_toBottomOf="@+id/tv_username" />

    <EditText
        android:id="@+id/et_username"
        android:layout_width="200dp"
        android:layout_height="wrap_content"
        app:layout_constraintBottom_toBottomOf="@+id/tv_username"
        app:layout_constraintStart_toStartOf="@+id/guideline" />

    <EditText
        android:layout_width="200dp"
        android:layout_height="wrap_content"
        app:layout_constraintBottom_toBottomOf="@+id/tv_password"
        app:layout_constraintStart_toEndOf="@+id/tv_password" />
</androidx.constraintlayout.widget.ConstraintLayout>
```

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20220309202254574.png" alt="image-20220309202254574" style="zoom:50%;" />



### ConstraintHelper

Group,Layer,Barrier(屏障),CircularRevealHelper都是ConstraintHelper的子类，他们都可以通过`constraint_referenced_ids` 属性处理一组控件的布局。

Group：控制多个控件的visibility ="gone/visible"。

Layer：控制多个控件的旋转/缩放/ 位移。

Barrier：通过设置⼀组控件的某个⽅向的屏障，来 避免布局嵌套 。

CircularRevealHelper：为一组控件设置动画

#### Group

使用相对布局通过 constraint_referenced_ids 使⽤引⽤的⽅式来避免布局嵌套，

你会很少为控件嵌套父布局，当你想隐藏多个控件的时候除了find 多个view 的id来设置visibility，还可以用Group控件，为⼀组控件统⼀设置 setVisibility，但是**只有设置可⻅度的功能，不要指望这个来通知设置点击事件.**..

```xml
    <androidx.constraintlayout.widget.Group
            android:id="@+id/group"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            app:constraint_referenced_ids="view,view1,view7,view8" />
```

```java
// group 继承ConstraintHelper
public class Group extends ConstraintHelper {...}

public abstract class ConstraintHelper extends View {
  
    // 成员变量ids数组
    protected int[] mIds = new int[32];
    ...

    public ConstraintHelper(Context context) {
       ...
        this.init((AttributeSet)null);
    }

    public ConstraintHelper(Context context, AttributeSet attrs) {
    // 在init()方法中将Group的子控件Id都通过constraint_referenced_ids 属性存入在成员变量数组中
    protected void init(AttributeSet attrs) {
        if (attrs != null) {
  				 ...
            for(int i = 0; i < N; ++i) {
                int attr = a.getIndex(i);
                if (attr == styleable.ConstraintLayout_Layout_constraint_referenced_ids) {
                    this.mReferenceIds = a.getString(attr);
                  // 存入id
                    this.setIds(this.mReferenceIds);
                }
            }
        }

    }
    public void setTag(int tag, Object value) {
        if (this.mCount + 1 > this.mIds.length) {
            this.mIds = Arrays.copyOf(this.mIds, this.mIds.length * 2);
        }
			// 将 找到的id 赋值给成员变量，ids数组。
        this.mIds[this.mCount] = tag;
        ++this.mCount;
    }
    
    private void addID(String idString) {
        if (idString != null) {
         ...
				// 找到 R.id 对应的值
        if (tag != 0) { this.setTag(tag, (Object)null);}}
    }
      
      
		// 拆分属性`app:constraint_referenced_ids="view,view1,view7,view8"` 
    // 通过 `,` 字符，用逗号分隔的字符串为数组
    private void setIds(String idList) {
        if (idList != null) {
            int begin = 0;

            while(true) {
              // char 类型的44，也就是 `,`
                int end = idList.indexOf(44, begin);
                if (end == -1) {
                    this.addID(idList.substring(begin));
                    return;
                }

                this.addID(idList.substring(begin, end));
                begin = end + 1;
            }
        }
    }      
      
}      
```

#### Layer

和 Group 类似，同样通过引⽤的⽅式来避免布局嵌套，可以为⼀组控件统⼀设置旋转/缩放/ 位移。

引用id的方法和Group一样，因为也是继承自`ConstraintHelper`

Eg:

```kotlin
class Helpers : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_layer)
        findViewById<Button>(R.id.button).setOnClickListener {
            findViewById<Layer>(R.id.layer).rotation = 45f
            findViewById<Layer>(R.id.layer).translationY = 100f
            findViewById<Layer>(R.id.layer).translationX = 100f
        }

    }
}
```

activity_layer.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        >

    <Button
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            android:id="@+id/button"
            android:text="layer"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"/>



    <androidx.constraintlayout.helper.widget.Layer
            android:id="@+id/layer"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            app:constraint_referenced_ids="view,view1,view7,view8"
            tools:ignore="MissingConstraints" />


    <ImageView
            android:id="@+id/view1"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="48dp"
            android:src="@mipmap/ic_launcher"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

    <ImageView
            android:id="@+id/view"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:src="@mipmap/ic_launcher"
            app:layout_constraintStart_toEndOf="@+id/view1"
            app:layout_constraintTop_toTopOf="@+id/view1" />

    <ImageView
            android:id="@+id/view7"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginStart="80dp"
            android:layout_marginTop="72dp"
            android:src="@mipmap/ic_launcher"
            app:layout_constraintStart_toEndOf="@+id/view1"
            app:layout_constraintTop_toTopOf="@+id/view1" />

    <ImageView
            android:id="@+id/view8"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginStart="8dp"
            android:layout_marginTop="72dp"
            android:src="@mipmap/ic_launcher"
            app:layout_constraintStart_toEndOf="@+id/view1"
            app:layout_constraintTop_toTopOf="@+id/view1" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

![image-20220310102509007](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20220310102509007.png)

#### Barrier

通过设置⼀组控件的某个⽅向的屏障，来避免布局嵌套 。

引用	id的方法和Group一样，因为也是继承自`ConstraintHelper`

Eg： View1，和View2组的Barrier屏障线，两个ImageView以Barrier的End为start，这样无论View1/2的文字有多长，两个ImageView都在最长的文字的后面排列，不会造成覆盖。

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".Helpers">

    <androidx.constraintlayout.widget.Barrier
        android:id="@+id/barrier"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        app:barrierDirection="end"
        app:constraint_referenced_ids="view1,view2" />


    <TextView
        android:id="@+id/view1"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="长文字长文字长文字"
        android:textSize="32sp"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <TextView
        android:id="@+id/view2"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="52dp"
        android:text="长文"
        android:textSize="32sp"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@+id/view1" />

    <ImageView
        android:id="@+id/imageView2"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@mipmap/ic_launcher"
        app:layout_constraintStart_toEndOf="@id/barrier"
        app:layout_constraintTop_toTopOf="@+id/view1" />

    <ImageView
        android:id="@+id/imageView"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@mipmap/ic_launcher"
        app:layout_constraintStart_toStartOf="@+id/barrier"
        app:layout_constraintTop_toTopOf="@+id/view2" />


</androidx.constraintlayout.widget.ConstraintLayout>
```

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/Xnip2022-03-10_10-45-26.jpg" alt="Xnip2022-03-10_10-45-26" style="zoom:50%;" />

#### CircularRevealHelper

为一组控件设置动画，引用id的方法和Group一样，因为也是继承自`ConstraintHelper`。

```kotlin
class CircularRevealHelper(context: Context, attrs: AttributeSet) : ConstraintHelper(context, attrs) {

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  override fun updatePostLayout(container: ConstraintLayout) {
    super.updatePostLayout(container)
		//ConstraintHelper的ids有长度限制（32），所以要用referencedIds.forEach来遍历真正的控件id。
    referencedIds.forEach {
      val view = container.getViewById(it)
      val radius = hypot(view.width.toDouble(), view.height.toDouble()).toInt()

      ViewAnimationUtils.createCircularReveal(view, 0, 0, 0f, radius.toFloat())
        .setDuration(2000L)
        .start()
    }
  }
}

```

layout.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
        xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        >

    <ImageView android:layout_width="wrap_content" android:layout_height="wrap_content"
               app:layout_constraintStart_toStartOf="parent"
               app:layout_constraintEnd_toEndOf="parent"
               app:layout_constraintTop_toTopOf="parent"
               app:layout_constraintBottom_toBottomOf="parent"
               android:id="@+id/image"
               android:src="@mipmap/ic_launcher_round" />


    <ImageView android:layout_width="80dp" android:layout_height="80dp"
               app:layout_constraintStart_toStartOf="parent"
               app:layout_constraintEnd_toEndOf="parent"
               app:layout_constraintTop_toTopOf="parent"
               app:layout_constraintBottom_toBottomOf="parent"
               android:id="@+id/image2"
               android:src="@drawable/sun" app:layout_constraintHorizontal_bias="0.8"
               app:layout_constraintVertical_bias="0.299"/>


    <ImageView android:layout_width="80dp" android:layout_height="80dp"
               app:layout_constraintStart_toStartOf="parent"
               app:layout_constraintEnd_toEndOf="parent"
               app:layout_constraintTop_toTopOf="parent"
               app:layout_constraintBottom_toBottomOf="parent"
               android:id="@+id/image3"
               android:src="@drawable/wechat" app:layout_constraintHorizontal_bias="0.2"
               app:layout_constraintVertical_bias="0.299"/>


    <ImageView android:layout_width="80dp" android:layout_height="80dp"
               app:layout_constraintStart_toStartOf="parent"
               app:layout_constraintEnd_toEndOf="parent"
               app:layout_constraintTop_toTopOf="parent"
               app:layout_constraintBottom_toBottomOf="parent"
               android:id="@+id/image4"
               android:src="@drawable/ic_favorite_black_24dp" app:layout_constraintHorizontal_bias="0.5"
               app:layout_constraintVertical_bias="0.3"/>

    <org.devio.constraintlayoutstudy.CircularRevealHelper
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            app:constraint_referenced_ids="image,image2,image3,image4"
    />

</androidx.constraintlayout.widget.ConstraintLayout>
```

#### Flow

```java
Flow extends VirtualLayout{ ... } 


public abstract class VirtualLayout extends ConstraintHelper {
   ...
}
```

通过引⽤的⽅式来避免布局嵌套。

常用属性：

- 方向 orientation="horizontal" 
-  app:flow_wrapMode="chain" 约束链
  - wrapMode
  - chain 链式
  - aligned 对齐
  - none(默认)
-  垂直间距 ：   app:flow_verticalGap="16dp"  
-  横向间距： app:flow_horizontalGap="16dp"



注意这个控件是可以被测量的，所以对应⽅向上的值可能需要被确定（即不能只约束同⼀⽅ 向的单个约束）

Eg：网格布局：

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".FlowActivity">

    <androidx.constraintlayout.helper.widget.Flow
        android:id="@+id/flow"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="16dp"
        android:layout_marginTop="16dp"
        android:background="@color/colorAccent"
        android:orientation="horizontal"
        app:flow_wrapMode="chain"
        app:flow_verticalGap="16dp" 
        app:flow_horizontalGap="16dp"
        app:constraint_referenced_ids="view1,view2,view3,view4,view5,view6"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <View
        android:id="@+id/view1"
        android:layout_width="80dp"
        android:layout_height="80dp"
        android:background="@color/colorPrimaryDark" />

    <View
        android:id="@+id/view2"
        android:layout_width="80dp"
        android:layout_height="80dp"
        android:background="@color/colorPrimaryDark" />

    <View
        android:id="@+id/view3"
        android:layout_width="80dp"
        android:layout_height="80dp"
        android:layout_margin="8dp"
        android:background="@color/colorPrimaryDark" />

    <View
        android:id="@+id/view4"
        android:layout_width="80dp"
        android:layout_height="80dp"
        android:background="@color/colorPrimaryDark" />

    <View
        android:id="@+id/view5"
        android:layout_width="80dp"
        android:layout_height="80dp"
        android:background="@color/colorPrimaryDark" />

    <View
        android:id="@+id/view6"
        android:layout_width="80dp"
        android:layout_height="80dp"
        android:background="@color/colorPrimaryDark" />

</androidx.constraintlayout.widget.ConstraintLayout>
```



### Placeholder

通过 setContentId 来将指定控件放到占位符的位置。

```kotlin
class PlaceHolder : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_place_holder)
    }

    fun onClick(view: View) {
      // 将指定控件放到占位符位置
        findViewById<Placeholder>(R.id.placeholder).setContentId(view.id)
    }
}

```

activity_place_holder.xml：

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:id="@+id/constraintLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        tools:context="com.hencoder.PlaceHolder">

    <androidx.constraintlayout.widget.Placeholder
            android:id="@+id/placeholder"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:layout_marginTop="16dp"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

    <androidx.appcompat.widget.AppCompatImageView
            android:id="@+id/favorite"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:onClick="onClick"
            android:src="@drawable/ic_favorite_black_24dp"
            android:tint="#E64A19"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toStartOf="@id/mail"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

    <androidx.appcompat.widget.AppCompatImageView
            android:id="@+id/mail"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:onClick="onClick"
            android:src="@drawable/ic_mail_black_24dp"
            android:tint="#512DA8"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toStartOf="@id/save"
            app:layout_constraintStart_toEndOf="@id/favorite"
            app:layout_constraintTop_toTopOf="parent" />

    <androidx.appcompat.widget.AppCompatImageView
            android:id="@+id/save"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:onClick="onClick"
            android:src="@drawable/ic_save_black_24dp"
            android:tint="#D32F2F"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toStartOf="@id/play"
            app:layout_constraintStart_toEndOf="@id/mail"
            app:layout_constraintTop_toTopOf="parent" />

    <androidx.appcompat.widget.AppCompatImageView
            android:id="@+id/play"
            android:layout_width="48dp"
            android:layout_height="48dp"
            android:onClick="onClick"
            android:src="@drawable/ic_play_circle_filled_black_24dp"
            android:tint="#FFA000"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toEndOf="@+id/save"
            app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

### ConstraintSet

ConstraintLayout在代码中修改属性不使用Layout.Params而是使用 **ConstraintSet** 对象来动态修改布局。

Eg： 使用  constraintSet.applyTo应用ConstrainSet

```kotlin
class ConstraintSetX : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_constraint_set)
    }


    fun onClick(view: View) {
        val constraintLayout = view as ConstraintLayout
        val constraintSet = ConstraintSet().apply {
            clone(constraintLayout)
            connect(
                R.id.twitter,
                ConstraintSet.BOTTOM,
                ConstraintSet.PARENT_ID,
                ConstraintSet.BOTTOM
            )
        }
        constraintSet.applyTo(constraintLayout)
    }
}
```

activity_constraint_set.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:onClick="onClick">

    <androidx.appcompat.widget.AppCompatImageView
            android:id="@+id/twitter"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:src="@drawable/twitter"
            android:tint="#00ACED"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent" />


</androidx.constraintlayout.widget.ConstraintLayout>
```

当然，这样引用起来不是很方便，我们可以用自定义的ConstraintHelper来自定义多个ConstraintSet规则

```kotlin
class Linear(context: Context, attrs: AttributeSet) : VirtualLayout(context, attrs) {

    private val constraintSet: ConstraintSet by lazy {
        ConstraintSet().apply {
            isForceId = false
        }
    }

    override fun updatePreLayout(container: ConstraintLayout) {
        super.updatePreLayout(container)
        constraintSet.clone(container)

        val viewIds = referencedIds;
        for (i in 1 until mCount) {

            val current = viewIds[i]
            val before = viewIds[i - 1]

            constraintSet.connect(current, ConstraintSet.START, before, ConstraintSet.START)
            constraintSet.connect(current, ConstraintSet.TOP, before, ConstraintSet.BOTTOM)

            constraintSet.applyTo(container)
        }
    }
}
```

防⽌布局中有⽆ id 控件时报错，需要设置 isForceId = false

通过 ConstraintSet#clone 来从 xml 布局中获取约束集。

布局扁平化更加容易做过渡动画

在布局修改之前加上 TransitionManager 来⾃动完成过渡动画，只要开始和结束布局的元素和id保持一致就可以做到。

```kotlin
class ConstraintSetX : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_constraint_start)
    }

    fun onClick(view: View) {
        val constraintLayout = view as ConstraintLayout

        val constraintSet = ConstraintSet().apply {
            isForceId = false
            clone(this@ConstraintSetX,
                R.layout.activity_constraint_end
            )
        }
        TransitionManager.beginDelayedTransition(constraintLayout)
        constraintSet.applyTo(constraintLayout)
    }
}
```

activity_constraint_start.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    xmlns:tools="http://schemas.android.com/tools"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:onClick="onClick"
 >

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/twitter"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:src="@drawable/twitter"
        android:tint="#00ACED"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toStartOf="@+id/wechat"
        app:layout_constraintTop_toTopOf="parent" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/wechat"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/wechat"
        android:tint="#51C332"
        app:layout_constraintEnd_toStartOf="@+id/weibo"
        app:layout_constraintStart_toEndOf="@+id/twitter"
        app:layout_constraintTop_toTopOf="@+id/twitter" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/weibo"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/weibo"
        android:tint="#D32024"
        app:layout_constraintEnd_toStartOf="@+id/qzone"
        app:layout_constraintStart_toEndOf="@+id/wechat"
        app:layout_constraintTop_toTopOf="@+id/wechat" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/qzone"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/qzone"
        android:tint="#FFCE00"

        app:layout_constraintEnd_toStartOf="@+id/wechat_friend"
        app:layout_constraintStart_toEndOf="@+id/weibo"
        app:layout_constraintTop_toTopOf="@+id/weibo" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/wechat_friend"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/wechat_friend"
        android:tint="#51C332"
        app:layout_constraintEnd_toStartOf="@+id/qq"
        app:layout_constraintStart_toEndOf="@+id/qzone"
        app:layout_constraintTop_toTopOf="@+id/qzone" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/qq"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/qq"
        android:tint="#00ACED"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toEndOf="@+id/wechat_friend"
        app:layout_constraintTop_toTopOf="@+id/wechat_friend" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

activity_constraint_end.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    xmlns:tools="http://schemas.android.com/tools"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    >

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/twitter"
        android:onClick="onClick"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:src="@drawable/twitter"
        android:tint="#00ACED"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toStartOf="@+id/wechat"
        app:layout_constraintTop_toTopOf="parent" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/wechat"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/wechat"
        android:tint="#51C332"
        app:layout_constraintEnd_toStartOf="@+id/weibo"
        app:layout_constraintStart_toEndOf="@+id/twitter"
        app:layout_constraintTop_toTopOf="@+id/twitter" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/weibo"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/weibo"
        android:tint="#D32024"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toEndOf="@+id/wechat"
        app:layout_constraintTop_toTopOf="@+id/wechat" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/qzone"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:src="@drawable/qzone"
        android:tint="#FFCE00"
        app:layout_constraintEnd_toStartOf="@+id/wechat_friend"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/twitter" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/wechat_friend"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/wechat_friend"
        android:tint="#51C332"
        app:layout_constraintEnd_toStartOf="@+id/qq"
        app:layout_constraintStart_toEndOf="@+id/qzone"
        app:layout_constraintTop_toTopOf="@+id/qzone" />

    <androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/qq"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/qq"
        android:tint="#00ACED"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toEndOf="@+id/wechat_friend"
        app:layout_constraintTop_toTopOf="@+id/wechat_friend" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

---
title: Android注解
date: 2022-01-19 11:08:55
categories: 
- Android
- 注解
tags: 
- Android
- 注解
---

# 注解

## 前言

注解，也被称为元数据，为我们在代码中添加信息提供了一种形式化的方法，使我们可以在稍后某个时刻非常方便地使用这些数据。（Java编程思想）
很多文章都是讲述java注解的，而且很多例子虽然有和Android互通的部分，但是Android开发中也扩展了很多单纯Java中没有的注解应用。所以这里主要介绍Android开发中的注解，当然包括Java注解。
目前很多框架开发或者Android开发中都用到了注解，SDK开发中也有很多可以对接口添加限制以规范用户使用的规则，这些都是值得我们去学习的。

## Java注解

Java 注解（Annotation）又称 Java 标注，是 JDK5.0 引入的一种注释机制。 Java 语言中的类、方法、变量、参数和包等都可以被标注。和 Javadoc 不同，Java 标注可以通过反射获取标注内容。在编译器生成类文件时，标注可以被嵌入到字节码中。Java 虚拟机可以保留标注内容，在运行时可以获取到标注内容 。 当然它也支持自定义 Java 标注。

### 内置标准注解

**Java内置了三种标准注解，其定义在java.lang中**：

1. @Override，表示当前的方法定义将覆盖超类中的方法。

2. @Deprecated，被此注解标记的元素表示被废弃，如果程序员使用了注解为它的元素，那么编译器会发出警告。

3. @SuppressWarnings，关闭不当的编译器警告信息。

   这几种注解我们平时开发中肯定经常用到，但是你可能很少看到注解原来的样子。如下为注解的类，可以看到，除了@符号的使用以外，它基本与Java固有语法一致。只是注解上又增加了其他注解。

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
public @interface Override {
}

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(value={CONSTRUCTOR, FIELD, LOCAL_VARIABLE, METHOD, PACKAGE, PARAMETER, TYPE})
public @interface Deprecated {
}

@Target({TYPE, FIELD, METHOD, PARAMETER, CONSTRUCTOR, LOCAL_VARIABLE})
@Retention(RetentionPolicy.SOURCE)
public @interface SuppressWarnings {
    String[] value();
}

```

注解的注解就是，元注解，专职负责注解其他的注解。

### 元注解

| 元注解      | 说明                             | 取值                                                         |
| ----------- | -------------------------------- | ------------------------------------------------------------ |
| @Target     | 表示该注解可以用在什么地方       | ElementType.ANNOTATION_TYPE 可以应用于注释类型。<br/>ElementType.CONSTRUCTOR 可以应用于构造函数。<br/>ElementType.FIELD 可以应用于字段或属性。ElementType.LOCAL_VARIABLE 可以应用于局部变量。<br/>ElementType.METHOD 可以应用于方法级注释。<br/>ElementType.PACKAGE 可以应用于包声明。<br/>ElementType.PARAMETER 可以应用于方法的参数。ElementType.TYPE 可以应用于类的任何元素。 |
| @Retention  | 表示需要在什么级别保存该注解信息 | 1.SOURCE:在源文件中有效（即源文件保留）<br/>2.CLASS:在class文件中有效（即class保留）<br/>3.RUNTIME:在运行时有效（即运行时保留） |
| @Documented | 表示将此注解包含在Javadoc中      | 无                                                           |
| @Inherited  | 表示允许子类继承父类中的注解     | 无                                                           |
|             |                                  |                                                              |

经过对元注解的表格进行理解，可以回头看我们平常使用的标准注解Override 、Deprecated 和SuppressWarnings 。可以看到他们分别都由元注解进行了注释，并且我们能够明白，为啥@Override只能用在方法上（@Target），而不能用在类、构造函数、变量上，而@Deprecated就可以用在构造函数、变量、方法、包、参数等，因为其代表的意义就可以表示它能够标注的所有类型都是废弃的元素。

### Java程序或者Android程序的三个阶段

我们在as或者idea等IDE开发时的Java源码时期，即SOURCE实际。然后经过gradle或其他构件工具编译，变成了.Class文件，在Android apk中的dex文件中都是.class文件，此时即Retention的Class时期。之后便是程序运行阶段，变成Jvm运行的RUNTIME时期，此时应用是执行状态，如果定义注解为RUNTIME，则此时的注解是保留的。

java的三个标准注解的@Retention，有两个是RetentionPolicy.SOURCE，一个是RetentionPolicy.RUNTIME。从上述表格可以了解，source即源文件保留，即是.java文件中保留。Runtime即运行时有效，即在Android应用在运行时还会存在，当然如果是java程序运行时也保留。可以理解为@Override 注释的方法，只在代码开发时有用即编码时可以覆盖父类方法，编译后和运行中这个注解代表的意义就没有了。
大多数时候，程序员主要是用元注解定义自己的注解，并编写自己的处理器来处理它们，文章最后会简单的写个自定义注解并应用以加深理解。

### 扩展

上边是经典的Java注解介绍，由于我们的Java开发都是基于JDK的，所以上述源码定义都在JDK的源码中。而由于新的JDK对旧版进行了扩充。
如@Repeatable 即是@since 1.8。 从JDK1.8引入的，可能使用比较少见，笔者也没见过这个的应用目前。**但是提这个的目的即任何语法都是供加速开发或者其他目的添加的，只不过我们自定义注解是为了我们自己的逻辑、或者做框架的是为了使用框架的人方便， JDK的开发人员是为了所有Java开发和他们自己方便。所以虽然我们不是定义JDK语言的，但是我们任何人开发都可以使用注解这种方式，为我们的代码和框架服务。注解是不断变化并发展的，当然我们Java或Android开发也是。**
package java.lang.annotation;

```java
/**
 * The annotation type {@code java.lang.annotation.Repeatable} is
 * used to indicate that the annotation type whose declaration it
 * (meta-)annotates is <em>repeatable</em>. The value of
 * {@code @Repeatable} indicates the <em>containing annotation
 * type</em> for the repeatable annotation type.
 *
 * @since 1.8
 * @jls 9.6 Annotation Types
 * @jls 9.7 Annotations
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Repeatable {
    /**
     * Indicates the <em>containing annotation type</em> for the
     * repeatable annotation type.
     * @return the containing annotation type
     */
    Class<? extends Annotation> value();
}

```

## Android注解

本来在Android系统源码中/frameworks/base/core/java/android/annotation中是有很多的注解的，但是呢，他们都是系统源码用的注解，不是给我们这种开发人员用的，因为所有的注解的注释上都有@hide注释。

```java
 * {@hide}
 */
@Documented
@Retention(SOURCE)
@Target({METHOD, PARAMETER, FIELD})
public @interface AnyRes {
}
```

Android系统给我们提供的SDK中，只有两个原生注解。位于android.annotation包中
@TargetApi 使高版本API的代码在低版本SDK不报错。
@SuppressLint 使用此标注让Lint忽略指定的警告。
举例：
@SuppressLint(“NewApi”）屏蔽一切新api中才能使用的方法报的android lint错误。 @SuppressLint(“HandlerLeak”) 在主线程用Handler处理消息出现时会有警告，提示你，这块有内存泄露的危险，handler最好声明为static的

然后系统以另外的形式即Android Support方式提供给我们其他的注解。这些注解不是默认加载的，它们被包装为一个单独的库。Support Library现在是由一些更小的库组成的，包括：v4-support、appcompat、gridlayout、mediarouter等等。当然这里的注解是没有@hide注释的，只是需要开发者去加载对应的dependence。然后Android Studio实在基于这些注解来检查代码中的潜在问题了。如果升级到androidx，也有对应的dependence。

```groovy
dependencies {
    compile 'com.android.support:support-annotations:XXX'
}
```

Nullness Annotations 参数
@NonNull 该注释表明使用的参数或者返回值不能为null
如果本地变量已知为空，并且我们申明了@NonNull, IDE会使用Warn警告提醒存在潜在的崩溃。
@Nullable 注释表明使用的的参数或者返回值可以为null
Resource Annotations，资源引用限制类：用于限制参数必须为对应的资源类型。
AnimatorRes ：animator资源类型
AnimRes：anim资源类型
AnyRes：任意资源类型
ArrayRes：array资源类型
AttrRes：attr资源类型
BoolRes：boolean资源类型
ColorRes：color资源类型
DimenRes：dimen资源类型。
DrawableRes：drawable资源类型。
FractionRes：fraction资源类型
IdRes：id资源类型
IntegerRes：integer资源类型
InterpolatorRes：interpolator资源类型
LayoutRes：layout资源类型
MenuRes：menu资源类型
PluralsRes：plurals资源类型
RawRes：raw资源类型
StringRes：string资源类型
StyleableRes：styleable资源类型
StyleRes：style资源类型
TransitionRes：transition资源类型
XmlRes：xml资源类型

作用举例：资源里的R.layout.*和R.string.*,二者都是int值，在源码阶段，如果在setContentView（值）的值设为R.string.* 理论上是不是也能编译通过？但是实际上不能，如果你这样做了，就会显示红色警告，为什么呢。

原因就在源码里，我们可以点进去看源码。在setContentView的参数里有**@LayoutRes**的注解，告诉用户这个int值必须是代表layout的。其他的资源类注解同理

```java
Override
public void setContentView(@LayoutRes int layoutResID) {
    getDelegate().setContentView(layoutResID);
}
```

Thread annotations 线程执行限制类：用于限制方法或者类必须在指定的线程执行。如果方法代码运行线程和标注的线程不一致，则会导致警告。
@AnyThread
@BinderThread
@MainThread
@UiThread
@WorkerThread

Value Constraint Annotations 类型范围限制类：用于限制标注值的值范围

@FloatRang
@IntRange
如下为@FloatRange的注释上的示例， 其代表返回值为从0.0-1.0直接的float值。

```java
	/**
 * Denotes that the annotated element should be a float or double in the given range
 * <p>
 * Example:
 * {@code
 * 	@FloatRange(from=0.0,to=1.0)
 *  public float getAlpha() {
 *      ...
 *  }
```

类型定义类：用于限制定义的注解的取值集合

@IntDef int型除了被作为资源引用传递之外，还经常被作为一种“枚举”类型来使用。在创建一个注解的同时列出所有可用的有效值，然后再使用这个注解。也就是说@IntDef是用来修饰注解的注解（元注解），用它所修饰的注解在使用时就限定了被修饰对象的可取值范围。
@StringDef 类似IntDef，列举出所有String的取值范围。

如下为Intdef的源码，可以看出，其@Target为ANNOTATION_TYPE，和前边java的元注解一致，所以这两个也是元注解。

```java
@Retention(CLASS)
@Target({ANNOTATION_TYPE})
public @interface IntDef {
    /** Defines the allowed constants for this element */
    long[] value() default {};

    /** Defines whether the constants can be used as a flag, or just as an enum (the default) */
    boolean flag() default false;
}
```

这里继续举例说明，自定义了一个Weather注解，而且定义了取值范围，即IntDef中包含的选型。

```java
	  public static final int SUNNY = 1;
    public static final int CLOUDY = 2;
    public static final int RAIN = 3;
    public static final int SNOW = 4;

    @Target(ElementType.PARAMETER)
    @IntDef({
        SUNNY,
        CLOUDY,
        RAIN,
        SNOW
    })
    @Retention(RetentionPolicy.SOURCE)
    public @interface Weather {
    }
    
    public void setWeather(@Weather int weather){
        
    }
```

使用时，如果传入IntDef中定义的值，则显示正常，否则编译器会出发红色警告。虽然，2值是包含在IntDef取值范围的int值，但是仍不允许，必须写对应常量。

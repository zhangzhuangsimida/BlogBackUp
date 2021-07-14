---
title: Kotlin进阶-hencoder
date: 2021-07-13 15:20:20
categories:
- Kotlin
tags:
- Kotlin
---

## 构造器

### 次级构造

```kotlin
class CodeView : TextView { 
	constructor(context: Context): super(context)
}
```

### 主构造器

```kotlin
class User constructor() {
    var username: String? = null
		// 主构造器如果没有被调用过就会报错，这里的 ：this（）就是调用了无参的主构造器，类似super（）
    constructor(username: String?): this(){
        this.username = username 
    }   
}
```

```kotlin
class CodeView constructor(context: Context) : TextView(context)
// 如果没有被「可⻅性修饰符」「注解」标注，那么 `constructor` 可 以省略
class CodeView (context: Context) : TextView(context)
```

成员变量初始化可以直接访问到主构造参数

```kotlin
class CodeView constructor(context: Context) : TextView(context){
	val color = context.getColor(R.color.white)
}
```

### init 代码块

主构造不能包含任何的代码，初始化代码可以放到 init 代码块中

```kotlin
class CodeView constructor(context: Context) : TextView(context) {
	init { 
  // init 中可以访问主构造参数
    paint.color = getContext().getColor(R.color.colorAccent)
  } 
}
```

在初始化的时候，初始化块会按照它们在「文件中出现的顺序」执行。

```kotlin
class CodeView constructor(context: Context) : TextView(context) {
init { // ...}
val paint = Paint() // 会在 init{} 之后运行 ,所以如果init用到了这个变量，要将它放在init前面，否则会报错
}
```

### 构造属性

在主构造参数前面加上 `var/val `使构造参数同时成为成员变量

```kotlin
class User constructor(var username: String?, var password: String?, var code:String?)
```

成员变量初始化可以直接访问到主构造参数，但是在方法中如果构造属性没有定义成`varj.val`在类的方法中是无法访问到构造参数的。

## data class

一些常见的功能交给编译器，通过语法糖实现：

```kotlin
data class User constructor(var username: String?, var password: String?, var code: String?) {
    //this(null,null,null) 调用一下主构造器
    constructor(): this(null,null,null)
}
```

数据类同时会生生成

-  toString()
- hashCode()
- equals()
- copy() (浅拷⻉) 
- componentN() ...

### 解构

Android Studio 点击 Tool  -〉Kotlin -〉Show Kotlin Byte Code 可以看到Kotlin对应的Java代码

可以把一个对象「解构」成很多变量，Kotlin会把解析的变量对应到构造属性上去

```kotlin
data class Response(var code: Int , var message: String ,var body: User)
fun execute(): Response {
    println("正在请求网络...")
    println("网络请求成功！")

    var code = 200
    var message = "OK"
    val user = User()
    return Response(code,message,user)
}
fun main() {
	//Java中取值的方法 
	val response = execute()
  val code = response.code
  val message = response.code
  val user = response.body
	//kotlin的解构取值方法
	val (code, message, body) = response 
	//等同于
	val code = response.component1() 
	val message = response.component2() 
	val body = response.component3()
}
```

使用data class 则拥有component1，component2.. 的解构能力，若不使用component1，component2等解构值需要手写补充

## 相等性

- `==` 结构相等 (调用 equals() 比较 )
- `===` 引用(地址值)相等

## Elvis 操作符

可以通过` ?: `的操作来简化` if null` 的操作

```kotlin
// lesson.date 为空时使用默认值
val date = lesson.date?: "日期待定"
// lesson.state 为空时提前返回函数 
val state = lesson.state?: return
// lesson.content 为空时抛出异常
val content = lesson.content ?: throw IllegalArgumentException("content expected")

if (user.username?.length ?:0 <4)
//等同于
if (user.username != null && user.username!!.length < 4)
// 因为若username =null 则. length = null 得到默认值0 ，小于4
// 若username ！=null 则第二个？的默认赋值会被忽略
```

## **when** 操作符

`when` 表达式可以接受返回值，多个分支相同的处理方式可以放在一起，用逗号分隔

```kotlin
 val colorRes = when (lesson.state) { 
   //多条件相同结果，可以摆在一起用, 分割
  Lesson.State.PLAYBACK, null -> R.color.playback 
  Lesson.State.LIVE -> R.color.live 	
  Lesson.State.WAIT -> R.color.wait
}
```

`when `表达式可以用来取代 `if-else-if `链。如果不提供参数，所有的分支条件都是布尔表达式

```kotlin
val colorRes = when {
	(lesson.state == Lesson.State.PLAYBACK) ->R.color.playback
	(lesson.state == null) -> R.color.playback 
	(lesson.state == Lesson.State.LIVE) -> R.color.live 
	(lesson.state == Lesson.State.WAIT) -> R.color.wait 
	else -> R.color.playback
}
```

## operator

通过 `operator `修饰「特定函数名」的函数，例如` plus` 、` get` ，可以达到重载运算符的效果

| 表达式 | 翻译为     |
| :----- | :--------- |
| a + b  | a.plus(b)  |
| a - b  | a.minus(b) |
| a * b  | a.times(b) |
| a / b  | a.div(b)   |

比如 

```kotlin
 holder.onBind(list[position])
// arraylist 可以像数组一样获得元素，是因为[]使用了operator操作符
// public operator fun get(index: Int): E

```



## lambda

如果函数的最后一个参数是 `lambda` ，那么 `lambda` 表达式可以放在圆括号之外:

```kotlin
lessons.forEach(){ 
	lesson : Lesson ->
		// ...
}
```

如果你的函数传入参数只有一个 `lambda` 的话，那么小括号可以省略的:

```kotlin
lessons.forEach { 
 lesson : Lesson ->
	// ...
}
```

如果 `lambda `表达式只有一个参数，那么可以省略，通过隐式的` it `来访问

```kotlin
lessons.forEach { // it
   // ...
}
```

## 循环

通过标准函数 repeat() :

```kotlin
repeat(100) {
  // 其实有两个参数，第二个是lambda，由于只有一个参数，所以可以挪到外面，打印结果为0到99
  println(it)
}
```

通过区间:

```kotlin
for (i in 0..99) { }
// until 不包括右边界，所以适合遍历数组(自带-1)
for (i in 0 until array.size) { }
for (i in 0 until 100) { }

```

## infix 函数

必须是成员函数或扩展函数

必须只能接受一个参数，并且不能有默认值

```kotlin
// until() 函数的源码
public infix fun Int.until(to: Int): IntRange {
	if (to <= Int.MIN_VALUE) return IntRange.EMPTY
	return this .. (to - 1).toInt() 
}
// 使用这个函数就能省略.和（）所以0 until 100 其实等同于 0.util(100)
```

## 嵌套函数

Kotlin 中可以在函数中继续声明函数,会消耗性能，除非真的需要提升可读性，否则不建议这样做。

```kotlin
fun func(){
	fun innerFunc(){} 
}
```

- 内部函数可以访问外部函数的参数
- 每次调用时，会产生一个函数对象
- 声明函数要在调用之前，嵌套函数不会提升

## 注解使用处目标

当某个元素可能会包含多种内容(例如构造属性，成员属性)，使用注解时可以通过 「注解使用处目标」，让注解对目标发生作用，例如 `@file: `、 `@get: `、`@set: `等。

- ` @file:` 作用于整个kt文件，Java调用里面的方法不用增加`Kt`大写`@file:JvmName("KotlinUtils")`
- `@get:`作用于`get`方法
- `@set:`作用于`set`方法

```kotlin
class BaseApplication : Application() {
    companion object {
        @JvmStatic//修改成真正的静态类
        @get:JvmName("currentApplication")//作用于get方法，Java调用时直接会调用currentApplication方法就等于调用get方法，不需要使用BaseApplication.Companion.getCurrentApplication()
        lateinit var currentApplication: Context
            private set//增加private 关键字，防止set被其他类调用
    }

    override fun onCreate() {
        super.onCreate()
        currentApplication = this
    }
}
```



## 函数

### 函数简化

类型推断简化函数声明：可以通过符号` =` 简化原本直接 `return `的函数

```kotlin
fun get(key :String) = SP.getString(key,null)
```

### 函数参数默认值

可以通过函数参数默认值来代替 Java 的函数重载

```kotlin
// 使用 @JvmOverloads 对 Java 暴露重载函数 
@JvmOverloads
fun toast(text: CharSequence, duration: Int = Toast.LENGTH_SHORT) {
	Toast.makeText(this, text, duration).show() 
}
```

由于第二个参数有默认值，调用的时候可以传单参数（第一个参数），也可以传双参数

由于Java中无法读取到Kotlin默认参数值的方法重载，所以要加上`@JvmOverloads`注解

### 扩展

#### 扩展函数

可以为任何类添加上一个函数，从而代替工具类

```kotlin
fun Float.dp2px(): Float {
    return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, this, displayMetrics)
}
```

扩展函数和成员函数相同时，成员函数优先被调用 

```kotlin
fun Activity.setContentView(id: Int) {} //这个扩展函数无法替换原有的成员函数
```

扩展函数是静态解析的，在编译时就确定了调用函数(没有多态)

```kotlin
fun Activity.log(text: String) { Log.e("Activity",text)}
fun Context.log(text: String) { Log.e("Context",text) }
//在activity中调用
log("toast")
(this as Context).log("toast")
//输出为 
Activity：toast 
Context： toast
//扩展函数是静态解析的，在编译时就确定了，不会互相覆盖
```

#### 扩展成员属性(简化函数)：

```kotlin
//activity 中增加成员属性
val ViewGroup.firstChild: View
	get() = getChildAt(0)

//onCreate 中调用
(window.decorView as ViewGroup).firstChild
```

### 函数类型

函数类型由「传入参数类型」和「返回值类型」组成，用「` -> `」连接，传入参数需 要用「` () `」，如果返回值为 `Unit `不能省略 

函数类型实际是一个接口，我们传递 函数的时候可以通过「 `::函数名` 」,或者「匿名函数」或者使用 「 `lambda` 」

如果传输的是接口而非函数类型，Kotlin已经做了优化，可以用lambda形式传递，也可以用object的形式传递。

```kotlin
class View {
    // 函数类型 是由 函数参数（接收类型）箭头-> 返回值组成的
    fun setOnClickListener(listener: (View) -> Unit) {
    }
} 
fun main() {
    val view = View()
    // 函数是可以传递的
    //::函数名 传递函数
    view.setOnClickListener(::onClick)
    //匿名函数 传递
    view.setOnClickListener(fun  (view: View) {
        println("被点击了")
    })
    //lambda 传递
    view.setOnClickListener {
        println("被点击了")
    }
}
fun onClick(view: View) {
    println("被点击了")
}    
```

Java 中调用：

```kotlin
  // kotlin 中的函数类型其实本质还是一个接口
        new View().setOnClickListener(new Function1<View, Unit>() {
            @Override
            public Unit invoke(View view) {
                return null;
            }
        });

        //lambda
        new View().setOnClickListener(view -> {
            System.out.println("ok");
            return null;
        });
```



### 内联函数

内联函数配合「函数类型」，可以减少「函数类型」生成的对象,减少函数的调用栈， 非函数类型使用内联函数对性能的提升很小。

使用` inline` 关键字声明的函数是「内联函数」，在「编译时」会将「内联函数」中的函数体直接插入到调用处。

所以在写内联函数的时候需要注意，尽量将内联函数中的代码行数减少!

```kotlin
fun main() {
    log("inline log")
}
//当函数没有inline时（普通函数）调用栈 main 入栈->log入栈->Log.e->log 出栈->main出栈 减少了调用栈
//当函数为inline 内联时调用栈： main 入栈->Log.e-> main出栈 减少了调用栈
inline fun log (text: String) {
    Log.e("Tag",text)
}
```



#### 部分禁用用内联

noinline 可以禁止部分参数参与内联编译

```kotlin
inline fun foo(inlined: () -> Unit, noinline notInlined: () -> Unit) {
	//......
}
```

### 具体化的类型参数

因为内联函数的存在，我们可以通过配合` inline + reified (具像化)`达到「真泛型」的 效果

```kotlin
val RETROFIT = Retrofit.Builder()
	.baseUrl("https://api.hencoder.com/") 
	.build()

// niline 内联
inline fun <reified T> create(): T { 
  return RETROFIT.create(T::class.java)
}
val api = create<API>()
// 普通调用
inline fun <reified T> create(clazz:Class<T>): T { 
  return RETROFIT.create(T::class.java)
}
val api = create<API::class.java>()
```



### Kotlin标准函数 

内置标准函数，也叫做作用域函数，通过他们我们可以将逻辑统一的代码放到同一块作用于，提高代码的可读性。

使用时可以通过简单的规则作出一些判断:

- 返回自身 -> 从` apply` 和 `also `中选
  - 作用域中使用 `this` 作为参数 ----> 选择 `apply`
  - 作用域中使用` it `作为参数 ----> 选择 `also`
- 不需要返回自身 -> 从 `run `和 `let `中选择
  - 作用域中使用` this` 作为参数 ----> 选择` run`
  - 作用域中使用` it `作为参数 ----> 选择` let`

`apply `适合对一个对象做附加操作的时候， 例如初始化属性,这样可以避免在init 中做初始化：

```kotlin
   private val paint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.STROKE
        color = getContext().getColor(R.color.colorAccent)
        this.strokeWidth = 6f.dp2px() // this 指代本 paint
    }
```

` let` 适合配合空判断的时候 (最好是成员变量，而不是局部变量，局部变量更适合用 if )

```kotlin
 lesson.state?.let {
                setText(R.id.tv_state, it.stateName())
                val colorRes = when (it) {
                    Lesson.State.PLAYBACK, null -> R.color.playback
                    Lesson.State.LIVE -> R.color.live
                    Lesson.State.WAIT -> R.color.wait
                }
                val backgroundColor = itemView.context.getColor(colorRes)
                getView<View>(R.id.tv_state)!!.setBackgroundColor(backgroundColor)
            }
```

`run`适合初始化view的时候，例如recyclerview，它不需要返回自身，且用`this`指代自身

` with `适合对同一个对象进行多次操作的时候

```kotlin
val result = with(user, {
        println("my name is $name, I am $age years old, my phone number is $phoneNum")
        1000
    })
```



## 抽象属性

在 Kotlin 中，我们可以声明抽象属性，子类对抽象属性重写的时候需要重写对应的 `setter/getter`

BaseVew:

```kotlin
// 虚拟属性
interface BaseView <T> {
   val presenter: T
}
```

Activity

```kotlin
class LessonActivity : AppCompatActivity(), BaseView<LessonPresenter?>,
    Toolbar.OnMenuItemClickListener {
    private val lessonPresenter = LessonPresenter(this)
    override val presenter: LessonPresenter?
        get() = lessonPresenter
        
}
```

### 委托 

#### 属性委托

有些常⻅的属性操作，我们可以通过委托的方式，让它只实现一次，例如:

- `lazy` 延迟属性:值只在第一次访问的时候计算 
- `observable` 可观察属性:属性发生改变时的通知 
- `map` 集合:将属性存在一个 map 中

对于一个只读属性(即 `val `声明的)，委托对象必须提供一个名为 `getValue() `的 函数

对于一个可变属性(即 `var `声明的)，委托对象同时提供` setValue() `、` getValue() `函数

属性委托需要`by` 关键字实现

```kotlin
// 这样做，presenter就会只被创建一次，且是在调用 时创建   
override val presenter: LessonPresenter by lazy {  LessonPresenter(this) }

```



### 类委托

可以通过类委托的模式来减少继承（将需要委托执行的方法委托给一个实体类）

类委托的编译器会优先使用自身重写的函数，而不是委托对象的函数

属性的get /set 方法委托类

```kotlin
    var token: String by Saver("token")
//        set(value) {
//            CacheUtils.save("token",value)
//        }
//        get() {
//            return CacheUtils.get("token")!!
//        }
//	 get set 方法被委托给了Saver方法
    class Saver(var token: String) {
        operator fun getValue(lessonActivity: LessonActivity, property: KProperty<*>): String {
            return CacheUtils.get("token")!!

        }

        operator fun setValue(lessonActivity: LessonActivity, property: KProperty<*>, s: String) {
            CacheUtils.save("token",token)
        }

    }
```



```kotlin
interface Base { 
  	fun print()
}
class BaseImpl(val x: Int) : Base { 
	override fun print() {
		print(x) 
	}
}
// Derived 的 print 实现会通过构造参数中的 b 对象来完成。 
class Derived(b: Base) : Base by b
```


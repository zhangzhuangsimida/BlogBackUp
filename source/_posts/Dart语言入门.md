---
title: Dart语言入门
date: 2021-07-16 15:24:52
categories:
- Flutter
- Dart
tags:
- Flutter
- Dart
---

# Dart 语言入门

## Dart基础知识

- 强类型语言，静态类型
  - Java ，C#等
- 面向对象 OOP
  - Python、C++、object-C、Java、Kotlin、Swift、C#、Ruby与PHP等
- JIT和AOT
  - 即时编译，开发期间、更快编译，更快的重载
  - AOT 事前编译，release期间更快更流畅

DartPad ：在线调试Dart https://dartpad.dev/?null_safety=true

<img src="https://img.mukewang.com/szimg/5d42d4b7091e771918913491.jpg" alt="知识体系" style="zoom: 25%;" />

## 变量、常量以及命名规则

dart是一个强大的脚本语言，可以不预先定义变量类型，会自动类型推断

```dart
  var str = '你好dart';
  print(str is String); // true

  var myNum = 1234;
  print(myNum is int); // true
```


dart变量命名区分大小写，Age和age是2个不同的变量


const和final
const值不变，一开始就得赋值

final可以开始不赋值，只能赋一次；而final不仅有const的编译时常量的特征，最重要的它是运行时常量，并且final是惰性初始化，即在运行时第一次使用前才初始化

如果要调用1个方法赋予1个常量，只能用final，如下：

// 如果要调用1个方法赋予1个常量，只能用final

```dart
 final a = new DateTime.now();
 print(a); // 2021-06-17 18:43:52.069089
```

如果使用const则报错：

```dart
const b = new DateTime.now(); // ERROR
print(b); // ERROR
```



##  常用数据类型

### 数字

- num ：dart数字类型的父类，即接受整型，也能接收浮点型，有两个子类
- int： 整型，num的子类
- double：双精度，num的子类

#### 数据类型转换

```dart
	 	num num1 = -1.0; //是数字类型的父类，有两个子类 int 和 double。 		
		//数据类型转换
    print(num1.abs()); //求绝对值
    print(num1.toInt()); //转int
    print(num1.toDouble()); //转double
    print(num1.toString());// 转String
```

### 字符串

#### 定义

使用单引号或双引号

```dart
String str1 = '字符串',str2 = "双引号";//字符串的定义
```

#### 创建多行字符串,保留内在格式

使用三个单引号或三个双引号 创建多行字符串,保留内在格式，如换行和缩进等，里面写什么输出就是什么(类似Kotlin)。

- 三个单引号

  ```
      String e = '''asd
       fdsd
         fff
      
      ''';
  ```

- 三个双引号　

  ```
  String f = """ 1
      2
      3
      4
      """;
  ```

2.1.2 后加入可空类型，和Kotlin中的用法一致。

```
  String? name ； 
```



#### 字符串模板

使用${} 将一个字符串变量/表达式嵌入到另一个字符串内

变量

```dart
String a1 = "aa";
String b1 = "bb${a1}bb";
print(b1); //bbaabb
```

表达式

```dart
 String a1 = "aa";
 String b2 = "bb${a1.toUpperCase()}bb";
 print(b2); //bbAAbb
```

### 常用方法


 ```dart
	  String str5 = '常用数据类型，请看控制台输出';
		print(str5.indexOf('类型')); //获取指定字符串位置， 输出：4
		String a5 = "a,d,d d,c,,";
    List<String> a6 = a5.split(",");//使用，分割，返回的是一个数组:[a, d, d d, c, , ]
    print(a6);
    String a3 = "aaabbbccc";
//字符串判断 是否包含或以xxx开始结束等
    print(a3.startsWith("aa")); // //是否以‘xxx’开头 输出：true
    print(a3.contains("ab")); // 从头开始判断 是否包含‘xx：输出：true
    print(a3.contains("ab", 3)); // 从index=3开始判断 是否包含‘xx：输出：false
//字符串替换
    String a4 = "abcdeab";
//替换全部符合条件的
    print(a4.replaceAll("ab","cc"));// 替换全部符合条件的 输出：cccdecc
 ```

### 布尔类型

`Dart `是强 bool 类型检查，只有`bool `类型的值是`true `才被认为是`true`

Dart使用`print`输出到控制台：

```dart
		///布尔类型，Dart 是强 bool 类型检查，只有bool 类型的值是true 才被认为是true
    bool success = true, fail = false;
    print(success);
    print(fail);
    print(success || fail); // true
    print(success && fail); // false	
```



### List集合

```dart
   ///集合初始化的方式
    List list = [1, 2, 3, '集合']; //初始化时，添加元素
    print(list);

    /// 集合泛型，指定数据类型
    List<int> list2 = [];
    //错误做法，类型转换错误,将一个动态数据类型，赋值给指定数据类型是会报错的，动态数据类型不是指定数据类型的子类
    // list2 = list;

    ///通过add 方法添加元素
    List list3 = [];
    list3.add('list3');
    list3.addAll(list);
    print(list3); // 输出：[list3, 1, 2, 3, 集合]

    /// 生成函数 generate
    List list4 = List.generate(
        3, (index) => index * 2); //arg1 集合长度，arg2 迭代器，index代表数组下标
    print(list4); // 输出：[0, 2, 4]

    /// 遍历
    for (int i = 0; i < list.length; i++) {
      print(list[i]);
    }
    for (var o in list) {
      print(o);
    }
    list.forEach((val) {
      print(val);
    });

    /// 常用方法
    /// remove
    print(list);
    list.remove('集合'); // 删除指定值的元素
    print(list); // [1, 2, 3]
    list.removeAt(1); //删除指定index的元素
    print(list); // [1, 3]
    list.insert(1, 2); //在指定index插入元素
    print(list); // [1, 2, 3]
    list.insertAll(3,[4,5]); //在指定index插入集合
    print(list); // [1, 2, 3, 4, 5]
    var sublist = list.sublist(0,3); //截取，第一个参数表示开始的位置，第二个参数为可选参数，表示结束的位置（包头不包尾）
    print(sublist); //[1, 2, 3]
    print(sublist.indexOf(2)); //指定元素在list中的坐标
```



### Map类型

map是将key和value相关联的对象，key和value都可以是任何类型的对象，并且key是唯一的如果key重复后面添加的key会替换前面的

```dart
 ///Map初始化
    Map names = {'xiaoming': '小明', 'xiaohong': '小红'};
    print(names);
    Map ages = {};
    ages['xiaoming'] = 16;
    ages['xiaohong'] = 18;
    print(ages);

    ///Map遍历
    ages.forEach((k, v) {
      print('$k $v');
    });

    Map ages2 = ages.map((k, v) {
      //迭代生成一个新Map 之后返回
      return MapEntry(v, k);
    });

    print(ages2);
    for (var key in ages.keys) {
      print('$key ${ages[key]}');
    }
    //作业
    //keys,values,remove，containsKey
    // map的
    print(ages2.keys); //属性返回表示键的可迭代对象。
    ages.keys.forEach((element) {
      print(element);// element 表示key对应的value
    });
    print(ages.containsKey("xiaoming")); //是否包含某个key，返回值bool
    ages.remove('xiaoming'); //根据key ，删除指定元素
    print(ages);
```



### dynamic、var、Object三者的区别

```dart
/// dynamic：是所有Dart对象的基础类型， 在大多数情况下，通常不直接使用它，
/// 通过它定义的变量会关闭类型检查，这意味着 dynamic x = 'hal';x.foo();
/// 这段代码静态类型检查不会报错，但是运行时会crash，因为x并没有foo()方法，所以建议大家在编程时不要直接使用dynamic；

///var：是一个关键字，意思是“我不关心这里的类型是什么。”，系统会自动推断类型runtimeType;数据类型一旦被定义就不能修改

///Object：是Dart对象的基类，当你定义：Object o=xxx；时这时候系统会认为o是个对象，你可以调用o的toString()和hashCode()方法
///因为Object提供了这些方法，但是如果你尝试调用o.foo()时，静态类型检查会进行报错；
///综上不难看出dynamic与Object的最大的区别是在静态类型检查上；

 		/// dynamic
    dynamic x = 'hal';
    print(x.runtimeType);//String
    print(x);//hal
    x = 123;
    print(x.runtimeType);//int
    print(x);//123

    /// var
    var a = 'hal';
    print(a.runtimeType);//String
    print(a);//hal

    /// object
    Object o1 = '111';
    print(o1.runtimeType);//String
    print(o1);// 111
    o1 = 123;
    print(o1.runtimeType);//int
    print(o1);//123
```

## 函数/方法

### 方法构成

`返回值类型 `+ `方法名` + `参数`

```
返回类型 方法名 （参数1，参数2,...）{
 方法体
 return 返回值
}
```

#### 返回值

返回值类型可缺省，也可为void或具体的类型。如果没有指定，默认return null 最后一句执行 

#### 参数

参数：参数类型和参数名，参数类型可缺省（另外，参数又分可选参数和参数默认值，可参考面向对象一节中构造方法部分的讲解）

##### 普通参数

```dart
 int sum(int val1, int val2) {
    return val1 + val2;
 }
```

##### 可选参数

- 可选命名参数`{param1,param2...}`

  ```dart
  void _buildThree(int num, {String name, int range}) {}
  ```

  调用包含可选命名参数的方法时，需要使用paramName:value的形式指定为哪个可选参数赋值，比如：

  ```dart
  _buildThree(10,range: 1);
  ```

- 可选位置参数`[param1,param2...]`

  ```dart
   void _buildHouse(int num, [String where, int range]) {}
   
   void _buildHouseAndDefaultValue(int num, [String where = 'Shanghai', int range]) { }
  ```

  调用包含可选位置参数的方法时，无需使用paramName:value的形式，因为 可选位置参数是位置，如果想指定某个位置上的参数值，则必须保证前面位置的已经有值,即使前面的值存在默认值。 比如：

  ```dart
  _buildHouse(10,10); //不可行的
  
  _buildHouse(10,'shenzhen',10); //可行的
  
  _buildHouseAndDefaultValue(10,10); //不可行的
  
  _buildHouseAndDefaultValue(10,'shenzhen',10); //可行的
  ```

##### 参数默认值

可以为可选参数添加默认值，比如:

```dart
 void _buildThree(int num, {String name, int range = 10}) {}
 void _buildHouseAndDefaultValue(int num, [String where = 'Shanghai', int range]) { }
```



### 方法特性

- 方法也是对象 ，并且有具体类型 Function

- 返回值类型、参数类型都可以省略

- 箭头语法: {=> expr }是`{return expr:}`的缩写，只适用于一个表达式

  ```dart
  int gender = 1;
  getPerson(name,age) => gender ==1 ? "name=$name,age=$age ": "Text";
  ```

  

### 方法类型

#### 入口方法

`main`方法:

```dart
void main() {
  runApp(MyApp());
}
```

#### 私有方法

`Dart`中的私有方法：方法前加下划线表示私有方法，只能在该类访问

```dart
/// 创建测试类
class TestFunction {
  /// 创建FunctionLearn对象
  FunctionLearn functionLearn = FunctionLearn();
 ...
  void privatePrint() {
    functionLearn._learn();
  }
}

class FunctionLearn {
	...
  /// 私有方法
  /// 通过——开头命名的方法
  /// 作用域是当前文件
  _learn() {
    print('私有方法');
  }
}
```

#### 匿名方法

大部分方法都带有名字，例如 main() 或者 print();
在Dart中你有可以创建没有名字的方法，称之为 匿名方法，有时候也被称为 lambda 或者 closure 闭包；
你可以把匿名方法赋值给一个变量， 然后你可以使用这个方法，比如添加到集合或者从集合中删除；
匿名方法和命名方法看起来类似— 在括号之间可以定义一些参数，参数使用逗号 分割，也可以是可选参数；
后面大括号中的代码为函数体：

```dart
 ([[Type] param1[, …]]) {
     codeBlock;
  };
```

```dart
var func = (str){
  print(str);
};
// 用() 将匿名函数括起来，再加() 可以直接调用匿名函数
((int n) {
  print(n); // 12
  print('我是自执行方法'); // 我是自执行方法
})(12); // 传入参数


class FunctionLearn {
 
  anonymousFunction() {
    var list = ['私有方法', '匿名方法'];
    /// 下面的代码定义了1个参数为element（该参数没有指定类型）的匿名函数
    /// list中的每个元素都会调用这个函数来打印出来，同时来计算了每个元素在list中的索引位置
    list.forEach((element) {
      print(list.indexOf(element).toString() + ': ' + element); // 打印是第几个元素
    });
  }
}
```

##### 把方法作为参数传递

把1个方法作为参数传递：

如下所示：

```dart
void main() {
  fn2(fn1); // fn1
}

fn1() {
  print('fn1');
}

fn2(fnName) {
  fnName(); // 执行传入的方法
}
```

##### 闭包

闭包: 函数嵌套函数, 内部函数会调用外部函数的变量或参数, 变量或参数不会被系统回收(不会释放内存)

- 可以赋值给变量，通过变量进行调用
- 可以在其他方法中直接调用或传递其他方法
- 能够访问外部方法内的局部变量，并持有其状态

全局变量特点：常驻内存，污染全局
局部变量：不常驻内存，会被垃圾机制回收，不会污染全局

想实现的功能：常驻内存但不污染全局，闭包可以解决这个问题

闭包的写法： 函数嵌套函数，并return 里面的函数，这样就形成了闭包。

```dart
void main() {
  var b = fn();
  b(); // 124
  b(); // 125
  b(); // 126
}

fn() {
  var a = 123; /*不会污染全局 常驻内存*/
  // 方法里面签套1个方法并返回这个方法，形成闭包
  return () {
    a++;
    print(a); // a同时具有全局变量和局部变量的特点
  };
}
```



## 面向对象（opp）

> 面向对象特点，封装，继承，多态。

### 类和对象

- 使用关键字 class 声明一个类
- 使用关键字new 创建一个对象，new可以省略
- 所有对象都继承于Objeckt类

定义一个Dart类，所有的类都继承自Object

```dart
/// 定义一个Dart类, 所有类都继承自Object
class Person {
  String name;
  int age;
  // 标准构造方法
  Person(this.name,this.age);
  ///重写父类的方法
  @override
  String toString() {
    return 'name:$name,age:$age';
  }
}
```

### 对象操作符

前三个跟Kotlin一样

- `?` 条件运算符 

- `as` 类型转换

- `is` 类型判断

- `..` 级联操作 （连缀）

  ```dart
    Person p1 = new Person('张三', 20);
    p1.printInfo(); // 张三 --- 20
  
    // 级联操作符
    p1
      ..name = '李四'
      ..age = 31
      ..printInfo(); // 李四 --- 31
  ```

  

#### 继承

- 使用关键字`extend` 继承一个类
- 子类会继承父类可见的属性和方法，不会继承构造方法
- 子类能够复写父类的方法，getter和setter
- 单继承，多态性

```dart
///继承：关键字 extends
class Student extends Person{
  //初始化子类构造方法时要调用父类的方法
  Student(String name, int age) : super(name, age);
}
```

#### 类和成员的可见性

- Dart中可见性以library库为单位
- 默认情况下每个Dart文件就是一个库
- 使用_表示库的私有性
- 使用import导入库

#### 属性和方法

- 默认属性会生成getter和setter方法
- 使用final 声明的属性只有getter 方法
- 属性和方法通过`.`访问
- 方法不能被重载

```dart
///继承：关键字 extends
class Student extends Person{
   //定义类的变量
  String _school;// 通过下划线来标识私有字段（变量）
  String city;
  String country;
  String name;
}
```

##### 静态成员

Dart中的静态成员：

- 用`static`关键字来实现类级别的变量和函数
- 静态方法不能访问非静态成员，非静态方法可以访问静态成员

静态属性和静态方法不需要实例化类，可以直接调用：即不需要`new`一个实例

```dart
// 定义静态属性和方法
class Person2 {
  static String name = '李四';

  static void show() {
    print(name);
  }
}
// 调用
Person2.show(); // 李四
```

定义1个`Person`类，其中`name`是静态属性，`printUserInfo()`是静态方法；`age`是类属性，`printInfo()`是类方法，那么可以得出：

- 非静态方法可以访问静态成员以及非静态成员

- 静态方法只能访问静态成员，不能访问非静态成员

```dart
void main() {
  Person p = new Person();

  // 非静态方法
  p.printInfo(); // 李四

  // 静态方法
  Person.printUserInfo(); // 李四
}

class Person {
  static String name = '李四';
  int age = 20;

  static void show() {
    print(name);
  }

  // 非静态方法可以访问静态成员以及非静态成员
  void printInfo() {
    // 调用静态成员不要用this，因为this表示实例化的类，静态成员和静态方法是属于类的
    print(name); // 调用静态属性
    print(this.age); // 调用非静态属性
  }

  // 静态方法只能访问静态成员，不能访问非静态成员
  static void printUserInfo() {
    print(name);
    // 静态方法无法访问非静态成员
    // print(this.age);  // ERROR
    // this.printInfo();  // ERROR
  }
}
```



##### 构造方法

如果不设置构造方法，会有一个默认的构造方法，

如果存在自定义的构造方法，则默认的构造方法无效

构造方法不能重载

###### 1. 标准构造方法

```dart
	// 默认构造函数
  Person() {
    print('这是构造函数的内容，这个方法在实例化的时候触发');
  }
//默认构造函数传入参数可以多次实例化

  Person(String name, int age) {
    this.name = name;
    this.age = age;
  }

 //上式可以简写为：使用this关键字

  // 默认构造函数的简写
  Person(this.name, this.age);

```



###### 2. 初始化列表

构造函数中`:`后面的表达式就是初始化列表

- 初始化列表会在构造函数方法体之前执行
- 使用，分隔初始化表达式
- 初始列表常用于设置final变量的值

```dart
//初始化列表：除了调用父类构造器，在子类构造器方法体之前，你也可以初始化实例变量，不同的初始化变量之间用逗号分隔开 
//如果父类没有默认构造方法（无参构造方法），则需要在初始化列表中调用父类构造方法进行初始化

Student(this._school, String name, int age,
      {this.city, this.country = 'China'})
      : name = '$country.$city',super(name, age);

class Person {
  String name;
  String age;
  final String gender;
  Person.withMap(Map map): name = map['name'],gender = map['gender']{
    age = map['age']
  }
}  
```



###### 3. 命名构造方法

命名构造方法：`[类名`+` .` +`方法名]`

Dart中默认构造函数只能1个，但是命名构造函数可以多个

```dart
	// 命名构造函数1
  Person.now() {
    print('我是命名构造函数');
  }

  // 命名构造函数2
  Person.setInfo(String name, int age) {
    this.name = name;
    this.age = age;
  }

```

调用命名构造函数：

```dart
void main() {

  Person p2 = new Person.now(); // 调用命名构造函数1
  Person p3 = new Person.setInfo('张云', 36); // 调用命名构造函数2
  p3.printInfo(); // 张云 --- 36
}
```



###### 4. 工厂构造方法

不仅仅是构造方法，更是一种模式,有时候为了返回一个之前已经创建的缓存对象，原始的构造方法已经不能满足要求,那么可以使用工厂模式来定义构造方法。

- 工厂模式构造方法类似于设计模式中的工厂模式
- 在构造方法前面加一个factory实现一个工厂构造方法
- 在工厂构造方法中可以返回对象

```dart
class Singleton {
  // 静态变量指向自身
  static final Singleton _instance = Singleton._();
  // 私有构造器
  Singleton._();
  // 方案1：静态方法获得实例变量
  static Singleton getInstance() => _instance;
  // 方案2：工厂构造方法获得实例变量
  factory Singleton() => _instance;
  // 方案3：静态属性获得实例变量
  static Singleton get instance => _instance;
}
```



###### 5. 命名工厂构造方法

命名工厂构造方法：`factory` [`类名`+`.`+`方法名`]

它可以有返回值，而且不需要将类的final变量作为参数，是提供一种灵活获取类对象的方式。

```dart
factory Student.stu(Student stu) {
    return Student(stu._school, stu.name, stu.age,
        city: stu.city, country: stu.country);
  }
```



##### setters /getters

```dart
 //可以为私有字段设置getter来让外界获取到私有字段
  String get school => _school;
  //可以为私有字段设置setter来控制外界对私有字段的修改
  set school(String value) {
    _school = value;
  }
```

##### 静态方法

```dart
  static doPrint(String str) {
    print('doPrint:$str');
  }
```

#### 抽象

##### 抽象类

Dart抽象类主要用于定义标准，子类可以继承抽象类，也可以实现抽象类接口。

- 抽象类通过abstract 关键字来定义

- Dart中的抽象方法不能用abstract声明，Dart中没有方法体的方法我们称为抽象方法。

- 如果子类继承抽象类必须得实现里面的抽象方法

- 如果把抽象类当做接口实现的话必须得实现抽象类里面定义的所有属性和方法。

抽象类不能被实例化，只有继承它的子类可以

`extends`抽象类 和` implements`的区别：

如果要复用抽象类里面的方法(用抽象类里面的公共方法)，并且要用抽象方法约束自类的话我们就用extends继承抽象类

如果只是把抽象类当做标准的话我们就用implements实现抽象类(重写抽象类中的方法)


```dart
abstract class Study {
  void study();
}
```

##### 抽象方法

继承抽象类要实现它的抽象方法，否则也需要将自己定义成抽象类

```dart
class StudyFlutter extends Study {
  @override
  void study() {
    print('Learning Flutter');
  }
}
```

##### 接口

Dart中的接口：

- Dart的接口没有interface关键字定义接口，而是普通类或抽象类都可以作为接口被实现。

- 但是dart的接口有点奇怪，如果实现的类是普通类，会将普通类和抽象中的属性的方法全部需要覆写一遍。

- 而因为抽象类可以定义抽象方法，普通类不可以，所以一般如果要实现像Java接口那样的方式，一般会使用抽象类。 建议使用抽象类定义接口。

案例：定义一个DB库 支持 mysql mssql mongodb，其中mysql mssql mongodb三个类里面都有同样的方法

如果在接口中定义了属性类型，继承接口的类中的方法也需要一致，比如add(String data)方法：

```dart
void main() {
  MySql mySql = new MySql('10.3.80.1');
  mySql.add('2021-06-24'); // 这是MySql的add方法 --- 10.3.80.1 --- 2021-06-24
}

// 定义1个抽象类，当作接口
abstract class Db {
  String uri; // 数据库链接地址
  // 当作接口，接口就是规范和约定
  add(String data);

  save();

  delete();
}

class MySql implements Db {
  @override
  String uri;

  // 构造函数
  MySql(this.uri);

  @override
  add(String data) {
    // 注意接口定义的参数属性
    print('这是MySql的add方法 --- ${this.uri} --- $data');
  }

  @override
  delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  save() {
    // TODO: implement save
    throw UnimplementedError();
  }
}

class MsSql implements Db {
  @override
  String uri;

  // 构造函数
  MsSql(this.uri);

  @override
  add(String data) {
    print('这是MsSql的add方法');
  }

  @override
  delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  save() {
    // TODO: implement save
    throw UnimplementedError();
  }
}

```

#### 一个类实现多个接口

个类实现多个接口，需要实现接口里面所有的属性和方法



```dart
void main() {
  C c = new C();
  c.printA(); // printA
  c.printB(); // printA
}

abstract class A {
  printA();
}

abstract class B {
  printB();
}

class C implements A, B {
  @override
  String name;

  @override
  printA() {
    print('printA');
  }

  @override
  printB() {
    print('printA');
  }
}
```



#### mixins

- 类似于多继承，是在多个类层次结构中重用代码的一种方式
- 作为 mixins类不能有显示声明的构造方法
- 作为Minxins的智能

因为mixins的使用条件随着Dart版本一直在变，这里以Dart 2.x为例：

- 作为mixins的类只能继承自Object，不能继承其他类
- 作为mixins的类不能有构造函数
- 1个类可以mixins多个mixins类
- mixins绝不是继承，也不是接口，而是一种全新的特性
Dart中无法实现多继承，但是可以实现多接口：

```dart
class C extends A, B {...} // EROOR
class C implements A, B {...} // OK
```

##### 基本使用

可以使用`mixins`实现类似多继承的功能，注意mixins的类必须继承自Object(如下A类和B类)，继承的C类可以访问A类和B类的属性以及方法，同时A类和B类不能有构造函数

```dart
void main() {
  C c = new C();
  c.printA(); // printA
  c.printB(); // printA
  print(c.info); // this is A
}

class A {
  String info = 'this is A';
  // A(this.info);  // ERROR
  void printA() {
    print('printA');
  }
}

class B {
  void printB() {
    print('printB');
  }
}

// C类mixins了A和B
class C with A, B {}
请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qq_34307801/article/details/118182383
```
##### 1个类可以mixins多个mixins类

作为`mixins`的类只能继承自Object，不能继承其他类

```dart
// C类不能mixins A类，因为A类继承了Person类不是Object
class A extends Person {
  String info = 'this is A';
  void printA() {
    print('printA');
  }
}
```

如下：C类既有Person类的功能，又有A类和B类的功能，注意因为Person类定义了默认构造函数，C类也要实现自己的构造函数：

```dart
void main() {
  C c = new C('张三', 20);
  c.printA(); // printA
  c.printB(); // printA
  c.printInfo(); // 张三 --- 20
}

class Person {
  String name;
  num age;

  Person(this.name, this.age);

  printInfo() {
    print('${this.name} --- ${this.age}');
  }
}

class A {
  String info = 'this is A';

  void printA() {
    print('printA');
  }
}

class B {
  void printB() {
    print('printB');
  }
}

// C类mixins了A和B,Person可以有构造函数，A,B不能有构造函数
// C类既有Person类的功能，又有A类和B类的功能
class C extends Person with A, B {
  C(String name, num age) : super(name, age);
}
```

如果Person类，A类和B类都有同样的方法，因为是`extend Person with A,B`，所以`c.run()`调用的是B类的run()方法：

```dart
void main() {
  C c = new C('张三', 20);
  c.printA(); // printA
  c.printB(); // printA
  c.printInfo(); // 张三 --- 20

  // Person类、A类和B类都有run()方法，但是因为是A,B，所有C类继承的是B.run()
  c.run(); // B is running!
}

class Person {
  String name;
  num age;

  Person(this.name, this.age);

  void run() {
    print('Person is running!');
  }

  printInfo() {
    print('${this.name} --- ${this.age}');
  }
}

class A {
  String info = 'this is A';

  void printA() {
    print('printA');
  }

  void run() {
    print("A is running!");
  }
}

class B {
  void printB() {
    print('printB');
  }

  void run() {
    print("B is running!");
  }
}

// C类mixins了A和B,Person可以有构造函数，A,B不能有构造函数
// C类既有Person类的功能，又有A类和B类的功能
class C extends Person with A, B {
  C(String name, num age) : super(name, age);
}


```

##### Mixins的类型

`mixins`的类型就是其超类的子类型

```dart
void main() {
  C c = new C();
  print(c is C); // true
  print(c is A); // true
  print(c is B); // true
  print(c is Object); // true
}

class A {
  String info = 'this is A';

  void printA() {
    print('printA');
  }
}

class B {
  void printB() {
    print('printB');
  }
}

class C with A, B {}
```



## 泛型

### 泛型类

前情回顾，如何创建指定长度及指定类型的List，List就是1个泛型类

```dart
List list = List.filled(2, '');
  list[0] = "张三";
  list[1] = "李四";
  print(list); // [张三, 李四]

  // 实例化List
  List list1 = new List.filled(2, "");
  list1[0] = "张云";
  list1[1] = "董磊";
  print(list1); // [张云, 董磊]

  // 指定List传入的数据必须是String类型
  List list2 = new List<String>.filled(2, "");
  list2[0] = "Ronaldo";
  list2[1] = "Messi";
  print(list2); // [Ronaldo, Messi]
```

目标：定义1个泛型类MyList，既可以增加int类型数据，也可以增加string类型数据，并且还可以实现类型的校验

实例化泛型类的时候如果不指定传入的类型，可以传入任意数据；如果指定了传入的类型，只能传入指定类型的数据

```dart
void main() {
  MyList list1 = new MyList<int>();
  list1..add(1)..add(2)..add(3);
  print(list1.getList()); // [1, 2, 3]

  // 没有指定传入MyList的类型
  MyList list2 = new MyList();
  list2..add('Ronaldo')..add('Messi')..add(1);
  print(list2.getList()); // [Ronaldo, Messi, 1]

  // 指定传入MyList的类型
  MyList list3 = new MyList<String>();
  // list3..add('张云')..add('董磊')..add(1); // ERROR
  list3..add('张云')..add('董磊')..add('成竹'); 
  print(list3.getList()); // [张云, 董磊, 成竹]
}

// 定义1个泛型类
class MyList<T> {
  //定义1个List属性
  List list = <T>[];

  void add(T value) {
    this.list.add(value);
  }

  List getList() {
    return this.list;
  }
}
```

有时候你在实现类似通用接口的泛型中，期望的类型是某些特定类型时，这时可以使用类型约束

```dart
class Member<T extends Person> {
  T _person;

  /// 泛型作用：约束参数类型
  Member(this._person);

  String fixedName() {
    return 'fixed:${_person.name}';
  }
}
```



### 泛型接口

定义1个泛型接口，可以对不特定数据类型进行校验

```dart
abstract class Cache<T> {
  getByKey(String key);

  void setByKey(String key, T value);
}
```

案例：

- 实现数据缓存的功能：有文件缓存和内存缓存，内存缓存和文件缓存按照接口的约束实现
- 定义1个泛型接口，约束实现它的子类必须有`getByKey(key)`和`setByKey(key,value)`
- 要求`setByKey`的时候的`value`的类型和实例化子类的时候指定的类型一致

```dart
void main() {
  MemoryCache m1 = new MemoryCache<String>();
  // m.setByKey('index', 123);  // ERROR
  m1.setByKey('index', '首页数据'); // 我是内存缓存，把<index 首页数据>的数据写入内存中

  MemoryCache m2 = new MemoryCache<Map>();
  Map person = {"name": '张三', "age": 30};
  m2.setByKey('index', person); // 我是内存缓存，把<index {name: 张三, age: 30}>的数据写入内存中
}

// 泛型接口
abstract class Cache<T> {
  getByKey(String key);

  void setByKey(String key, T value);
}

// 文件缓存类
class FileCache<T> implements Cache<T> {
  @override
  getByKey(String key) {
    return null;
  }

  @override
  void setByKey(String key, T value) {
    print('我是文件缓存，把<${key} ${value}>的数据写入文件中');
  }
}

// 内存缓存类
class MemoryCache<T> implements Cache<T> {
  @override
  getByKey(String key) {
    return null;
  }

  @override
  void setByKey(String key, T value) {
    print('我是内存缓存，把<${key} ${value}>的数据写入内存中');
  }
}
```

### 泛型方法

泛型解决了类、接口方法的复用性，以及对不特定数据类型的支持(l类型校验)

不指定类型放弃了类型检查，我们现在想实现的是传入什么，返回什么，比如传入number类必须返回number，同时还支持类型校验

```dart
void main() {
  // 指定了传入类型
  print(getData<String>('你好')); // 你好

  print(getData<int>(123)); // 123
}

// 不指定类型放弃了类型检查
// getData(value) {
//   return value;
// }

// 泛型方法，指定了传入类型，也指定了返回类型
T getData<T>(T value) {
  return value;
}
```

也可以只对传入参数进行校验，对返回参数不校验

```dart
// 只对传入参数进行校验，对返回参数不校验
getData1<T>(T value) {
  return value;
}
```

## 异步

### async await

这两个关键字只需要注意两点：

- 只有`async`方法才能使用`await`关键字调用方法
- 如果调用别的`async`方法必须使用`await`关键字

`async`是让方法变成异步；`await`是等待异步方法执行完成

因为在`main()`方法中使用了`await`，所以`main()`方法也必须是`async`方法

```dart
void main() async {
  var result = await testAsync();
  print(result); // Hello async
}

// 异步方法
testAsync() async {
  return 'Hello async';
}
```

### Future

### Stream

## 编程技巧

### 安全的调用

对于不确定是否为空的对象通过`?.`的来访问它的属性或方法以防止空异常，如：`a?.foo()`

### 使用`??`设置默认值

`list.length`为空的时候，默认值为-1	

```dart
print(list?.length ?? -1); // -1
```

### 类似ES6中的简化判断

使用contains方法：

```dart
  list = [];
  list.add(0);
  list.add('');
  list.add(null);
  
 if (list[0] == null || list[0] == '' || list[0] == 0) {
    print('list[0] is empty!'); // list[0] is empty!
  }
//等价于
 /// 简化代码判断，类似ES6方法
  if ([null, '', 0].contains(list[0])) {
    print('list[0] is empty!'); // list[0] is empty!
  }
```

## Dart 2.13后的新特性

Flutter 2.2.0（2021年5月19日发布）之后的版本都要求使用`null safety`(空安全)

- `?`可空类型
- `!`类型断言

`!`类型断言一般和`try/catch`配合使用，如下：

```dart
void main() {
  printLength('this is str'); // 11
  printLength(null); // str is null
}

void printLength(String? str) {
  // print(str!.length);
  // if (str != null) {
  //   print(str.length);
  // }
  try {
    print(str!.length);
  } catch (e) {
    print('str is null');
  }
}
```

### late关键字

`late`关键字主要用于延迟初始化属性

案例：Person类没有构造函数，稍后初始化类成员属性

```dart
// late关键字
void main() {
  Person p = new Person();
  p.setName('张三', 20);
  print(p.getName()); // 张三 --- 20
}

class Person {
  // String name; // non-nullable instance field 'name' must be initialized.
  // in age;// non-nullable instance field 'name' must be initialized.

  late String name; // 稍后初始化name
  late int age; // 稍后初始化age

  void setName(String name, int age) {
    this.name = name;
    this.age = age;
  }

  String getName() {
    return '${this.name} --- ${this.age}';
  }
}


```

### required关键字

基本使用
老版本Dart中使用@required注解代码，新斑斑中required已经作为内置修饰符，主要用于允许根据需要标记任何命名参数(函数或类)，使得它们不为空。因为可选参数中必须有个required：

之前定义命名参数的函数：sex有默认值”男“

```dart
String printUserInfo(String userName, {int age, String sex = '男'}) {
  if (age != null) {
    return '姓名：$userName --- 年龄：$age --- 性别：$sex';
  }
  return '姓名：$userName --- 年龄：保密 --- 性别：$sex';
}

```

使用`required`修饰的命名参数，必须有值传入，且不允许为null

```dart
void main() {
  // print(printUserInfo('张三')); // ERROR
  // print(printUserInfo('李四', age: null, sex: null)); // ERROR
  print(printUserInfo('张三', age: 20, sex: '男')); // 姓名：张三 --- 年龄：20 --- 性别：男
}

// 如果age和sex没有默认值，增加required关键字表示age和sex必须有初始值传入，不允许null
String printUserInfo(String userName, {required int age, required String sex}) {
  if (age != null) {
    return '姓名：$userName --- 年龄：$age --- 性别：$sex';
  }
  // age和sex必须传入
  return '姓名：$userName --- 年龄：${age} --- 性别：$sex';
}

```

### 类中使用

案例：`name`和`age`必须传入，且可以为null

```dart
void main() {
  Person p1 = new Person(name: '张三', age: 20);
  print(p1.getUserInfo()); // 张三 --- 20

  Person p2 = new Person(name: null, age: null);
  print(p2.getUserInfo()); // null --- null
}

class Person {
  String? name;  // 可空属性
  int? age;  // 可空属性

  // 命名参数的构造函数
  // 表示name和age是必须传入的命名参数
  Person({required this.name, required this.age});

  void setUserInfo(String name, int age) {
    this.name = name;
    this.age = age;
  }

  String getUserInfo() {
    return '${this.name} --- ${this.age}';
  }
}

```

## Dart 中的库

Dart中的库主要有三种：

- 我们自定义的库：

  ```dart
  import 'lib/xxx.dart'; 
  ```

- 系统内置库：

  ```dart
  import 'dart:math';    
  import 'dart:io'; 
  import 'dart:convert';
  ```

- Pub包管理系统中的库：
  https://pub.dev/packages
  https://pub.flutter-io.cn/packages
  https://pub.dartlang.org/flutter/

### Dart中库的重命名以及冲突如何解决

假设`Person1.dart`和`Person2.dart`含有同名称的实例类`Person`，那么引入的时候通过`as`关键字进行区分：

```dart
import 'lib/Person1.dart' as lib1;
import 'lib/Person2.dart' as lib2;

void main() {
  var p1 = lib1.Person('张三', 20);
  p1.printInfo(); // Person1：张三 --- 20

  var p2 = lib2.Person('李四', 32);
  p2.printInfo(); // Person2：李四 --- 32
}
```

### 库中方法部分导入

使用`show`关键字显示部分功能：

```dart
import 'lib/myMath.dart' show getName, getAge;
// import 'lib/myMath.dart' hide getName;

void main() {
  getName(); // 张三
  getAge(); // 20
}
```

使用hide关键字隐藏部分功能

```dart
// import 'lib/myMath.dart' show getName, ·getAge;
import 'lib/myMath.dart' hide getName;

void main() {
  // getName(); // ERROR
  getAge(); // 20
  getSex(); // 男
}

```

### 延迟加载

延迟加载也称为懒加载，可以在需要的时候再进行加载。 懒加载使用`deferred as`关键字来指定，如下例子所示：

```dart
import 'package:deferred/hello.dart' deferred as hello;

    // 当需要使用的时候，需要使用loadLibrary()方法来加载：
    greet() async {
      await hello.loadLibrary();
      hello.printGreeting();
    }
```


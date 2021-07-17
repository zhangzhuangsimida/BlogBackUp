---
title: Flutter快速入门
date: 2021-07-17 00:59:11
categories:
- Flutter
tags:
- Flutter
---

# 快速入门



## 从 Android角度理解Flutter

### Flutter和Android中的View

在Android中，View是屏幕上显示的所有内容的基础， 按钮、工具栏、输入框等一切都是View。 在Flutter中，View相当于是Widget。然而，与View相比，Widget有一些不同之处。 首先，Widget仅支持一帧，并且在每一帧上，Flutter的框架都会创建一个Widget实例树(译者语：相当于一次性绘制整个界面)。 相比之下，在Android上View绘制结束后，就不会重绘，直到调用invalidate时才会重绘。

与Android的视图层次系统不同（在framework改变视图），而在Flutter中的widget是不可变的，这允许widget变得超级轻量。

### 布局（声明式布局）



在Android中，您通过XML编写布局（命令式），但在Flutter中，您可以使用widget树来编写布局（声明式）。

这里是一个例子，展示了如何在屏幕上显示一个简单的Widget并添加一些padding。

```dart
@override
Widget build(BuildContext context) {
  return new Scaffold(
    appBar: new AppBar(
      title: new Text("Sample App"),
    ),
    body: new Center(
      child: new MaterialButton(
        onPressed: () {},
        child: new Text('Hello'),
        padding: new EdgeInsets.only(left: 10.0, right: 10.0),
      ),
    ),
  );
}
```

### 控件

| Android                            | Flutter         |
| ---------------------------------- | --------------- |
| View                               | Widget          |
| LinearLayout                       | Colum、Row      |
| RelativeLayout                     | Colum+Row+Stack |
| ScrollView、Recyclerview、ListView | ListView        |
| TextView                           | Text            |
| EditText                           | TextFeild       |

三方库

- [pub.dev](https://pub.dev/)


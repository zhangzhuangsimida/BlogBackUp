---
title: AndroidStudio疑难杂症
date: 2021-02-20 18:47:58
categories:
- Android 
- AndroidStudio
tags:
- Android 
- AndroidStudio
---

# Mac OS 下AndroidStudio手动下载gradle(自动下载太慢)
<!--more-->
1.获取url并下载
在gradle-wrapper.properties中获取url

distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-4.1-all.zip

```
#Thu Nov 29 10:32:13 CST 2018
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-4.1-all.zip

```
将https://services.gradle.org/distributions/gradle-4.1-all.zip复制到迅雷或其他工具下载，会很快。

2.放到gradle目录
mac下gralde目录在 ~/.gradle中

将下载的压缩包放到~/.gradle/wrapper/dists/gradle-4.1-all/生成的文件夹/ 下并解压

将gradle-4.1-all.zip.part文件删除；复制一份gradle-4.1-all.zip.lck文件，重命名为gradle-4.1-all.zip.ok；
点击Sync Project With Gradle Files。

![image-20210220185056937](AndroidStudio疑难杂症/image-20210220185056937.png)"“生成的文件夹”"是studio中gradle自动下载时生成的.

android gradle插件 和 gradle版本对应关系参见

https://developer.android.google.cn/studio/releases/gradle-plugin#updating-plugin

原文引用：https://blog.csdn.net/qq_26632895/article/details/108276511

感谢，特记录方便平时使用

# 无法执行Java Main 方法

.idea/gradle.xml 中增加属性
```
        <option name="delegatedBuild" value="false" />
```

### NDK无法找到

`NDK at ~/android-sdk-macosx/ndk-bundle did not have a source.properties file`

Studio 3.0之后

**这些文件都被存在在具体的ndk下， 如 …\SDK\ndk\21.1.6352462 ；
这个时候只要在项目的 local.properties 文件里加入具体ndk目录就行了，如下：**

```text
ndk.dir=D\:\\Android\\sdk\\ndk\\21.1.6352462
```


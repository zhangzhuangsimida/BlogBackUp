---
title: '自定义view绘制04:范围裁切和几何变换'
date: 2021-08-24 11:11:05
categories:
- Android
- 自定义View
tags:
- Android
- 自定义View
---

# 范围裁切和几何变换

## Canvas 的范围裁切

- clipRect： 切成矩形

  ```kotlin
   				//裁切 左上角
          canvas.clipRect(BITMAP_PADDING, BITMAP_PADDING,
              BITMAP_PADDING+ BITMAP_SIZE/2
              ,BITMAP_PADDING+ BITMAP_SIZE/2)
          canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING,paint)
  ```

  ![image-20210824113648691](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824113648691.png)

- clipPath() ：切封闭图形

   clipPath() 切出来的圆为什么没有抗锯⻮效果?因为「强行切边」，而xfermode会对边缘进行一些模糊处理

- clipOutRect() / clipOutPath() 反向版本，切的位置是不要的，其余位置留下

Eg:

```kotlin
private val BITMAP_SIZE = 200.dp
private val BITMAP_PADDING = 100.dp
@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class CameraView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val bitmap = getAvatar(BITMAP_SIZE.toInt())
    private val cliped = Path().apply {
        addOval(BITMAP_PADDING, BITMAP_PADDING,
            BITMAP_PADDING+ BITMAP_SIZE
            ,BITMAP_PADDING+ BITMAP_SIZE,Path.Direction.CCW)
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        //范围裁切
        // clipRect：裁切 左上角
//        canvas.clipRect(BITMAP_PADDING, BITMAP_PADDING,
//            BITMAP_PADDING+ BITMAP_SIZE/2
//            ,BITMAP_PADDING+ BITMAP_SIZE/2)
//        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING,paint)

        // clipPath：裁切 Path 圆形
        canvas.clipPath(cliped)
        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING,paint)

    }

    private fun getAvatar(width: Int): Bitmap {
        val options = BitmapFactory.Options()
        options.inJustDecodeBounds = true
        BitmapFactory.decodeResource(resources, R.drawable.avatar_rengwuxian, options)
        options.inJustDecodeBounds = false
        options.inDensity = options.outWidth
        options.inTargetDensity = width
        return BitmapFactory.decodeResource(resources, R.drawable.avatar_rengwuxian, options)
    }

}
```



## Canvas 的几何变换

- translate(x, y)平移
- rotate(degree) 旋转

- scale(x, y) 缩放

- skew(x, y) 错切（斜切）方形切棱形等操作

**重点:**

Canvas 的几何变换方法参照的是 View 的坐标系，而绘制方法 (drawXxx())参照的是 Canvas 自己的坐标系。

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824152046675.png" alt="image-20210824152046675" style="zoom:50%;" />

### 关于多重变换

Canvas 的变换方法多次调用的时候，由于 Canvas 的坐标系会整体被变换，因此当 平移、旋转、放缩、错切等变换多重存在的时候，Canvas 的变换参数会非常难以计 算，因此可以改用倒序的理解方式:

> 将 Canvas 的变换理解为 Canvas 的坐标系不变，每次变换是只对内部的绘制内 容进行变换，同时把 Canvas 的变换顺序看作是倒序的(即写在下面的变换先 执行)，可以更加方便进行多重变换的参数计算。

## Matrix的几何变换

- reTranslate(x, y) / postTranslate(x, y)
- preRotate(degree) / postRotate(degree) 
- preScale(x, y) / postScale(x, y)
- preSkew(x, y) / postSkew(x, y)

其中 preXxx() 效果和 Canvas 的准同名方法相同， postXxx() 效果和 Canvas 的准同名方法顺序相反。

### 注意

如果多次绘制时重复使用 Matrix，在使用之前需要用 Matrix.reset() 来把 Matrix 重置。

## 使用Camera做三维旋转

- rotate() / rotateX() / rotateY() / rotateZ() 
- translate()
- setLocation()

其中，一般只用 rotateX() 和 rorateY() 来做沿 x 轴或 y 轴的旋转，以及使 用 setLocation() 来调整放缩的视觉幅度。

对 Camera 变换之后，要用 Camera.applyToCanvas(Canvas) 来应用到 Canvas。

三维坐标轴

x： 右为正向 ，y：上为正向，z：向屏幕里面为正向

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824152852451.png" alt="image-20210824152852451" style="zoom:33%;" />

camera存在于空间中，面对沿x轴旋转的图片会呈现出T形

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824153154902.png" alt="image-20210824153154902" style="zoom:33%;" />

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824153223669.png" alt="image-20210824153223669" style="zoom:33%;" />

camera的轴心无法移动，我们可以移动画布，旋转后再移动回原位置

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824153516440.png" alt="image-20210824153516440" style="zoom:33%;" />



Eg：

```kotlin
 // camera
    private val camera = Camera()

    init {
        // 没指定轴心，默认为0，0
        camera.rotateX(30f)
    }
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        // Camera
        //对 Camera 变换之后，要用 Camera.applyToCanvas(Canvas) 来应用到 Canvas。
        //camera的轴心无法移动，我们可以移动画布，旋转后再移动回原位置（书写顺序要倒过来）
        canvas . translate (BITMAP_PADDING + BITMAP_SIZE / 2,
            BITMAP_PADDING + BITMAP_SIZE / 2)

        camera.applyToCanvas(canvas)

        canvas.translate(
            -(BITMAP_PADDING + BITMAP_SIZE / 2),
            -(BITMAP_PADDING + BITMAP_SIZE / 2))

        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING, paint)
    }
```

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824154045317.png" alt="image-20210824154045317" style="zoom:50%;" />

### setLocation

这个方法一般前两个参数都填（x,y） 0，第三个参数为负值(z)。由于这个值的单位是硬编码写 死的，因此像素密度越高的手机，相当于 Camera 距离 View 越近，所以最好把这个 值写成与机器的 density  成正比的一个负值，例如 -6 * density。

Camera距离太近投影看起来就很大：

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824154554418.png" alt="image-20210824154554418" style="zoom:50%;" />





```kotlin
        // 上半部分
        canvas.save()
        canvas.translate (BITMAP_PADDING + BITMAP_SIZE / 2,
            BITMAP_PADDING + BITMAP_SIZE / 2)

        canvas.clipRect(- BITMAP_SIZE, - BITMAP_SIZE/2, BITMAP_SIZE/2, 0f)
        canvas.translate(
            -(BITMAP_PADDING + BITMAP_SIZE / 2),
            -(BITMAP_PADDING + BITMAP_SIZE / 2))
        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING, paint)
        canvas.restore()

        // 下半部分
        canvas.translate (BITMAP_PADDING + BITMAP_SIZE / 2,
            BITMAP_PADDING + BITMAP_SIZE / 2)

        camera.applyToCanvas(canvas)
        canvas.clipRect(- BITMAP_SIZE, 0f, BITMAP_SIZE/2, BITMAP_SIZE/2)
        canvas.translate(
            -(BITMAP_PADDING + BITMAP_SIZE / 2),
            -(BITMAP_PADDING + BITMAP_SIZE / 2))
        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING, paint)

```

![image-20210824161105237](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824161105237.png)

斜切：转动canvas在裁切即可

旋转后需要扩大裁切范围，否则会裁切到原本的图片，裁切范围扩大两倍

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824161604856.png" alt="image-20210824161604856" style="zoom:50%;" />

```kotlin
package com.hencoder.customviewdrawing.clipandcamera

import android.content.Context
import android.graphics.*
import android.os.Build
import android.util.AttributeSet
import android.view.View
import androidx.annotation.RequiresApi
import com.hencoder.customviewdrawing.R
import com.hencoder.customviewdrawing.view.dp

/**
 * Created by amazingZZ on 8/24/21
 */

private val BITMAP_SIZE = 200.dp
private val BITMAP_PADDING = 100.dp

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class CameraView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val bitmap = getAvatar(BITMAP_SIZE.toInt())
    private val cliped = Path().apply {
        addOval(
            BITMAP_PADDING, BITMAP_PADDING,
            BITMAP_PADDING + BITMAP_SIZE
            , BITMAP_PADDING + BITMAP_SIZE, Path.Direction.CCW
        )
    }


    // camera
    private val camera = Camera()

    init {
        // 没指定轴心，默认为0，0
        camera.rotateX(30f)
        // 移动摄像机，单位不是像素是英寸（因为这个方法不是谷歌提供的，1英寸大概72像素）
        camera.setLocation(0f, 0f, -6 * resources.displayMetrics.density)
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        //范围裁切
        // clipRect：裁切 左上角
//        canvas.clipRect(BITMAP_PADDING, BITMAP_PADDING,
//            BITMAP_PADDING+ BITMAP_SIZE/2
//            ,BITMAP_PADDING+ BITMAP_SIZE/2)
//        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING,paint)

        // clipPath：裁切 Path 圆形
//        canvas.clipPath(cliped)
//        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING,paint)

        // Camera
        //对 Camera 变换之后，要用 Camera.applyToCanvas(Canvas) 来应用到 Canvas。

        //camera的轴心无法移动，我们可以移动画布，旋转后再移动回原位置（书写顺序要倒过来）
        // 上半部分
        canvas.save()
        canvas.translate (BITMAP_PADDING + BITMAP_SIZE / 2,
            BITMAP_PADDING + BITMAP_SIZE / 2)
        canvas.rotate(-30f)

        canvas.clipRect(- BITMAP_SIZE, - BITMAP_SIZE, BITMAP_SIZE, 0f)
        canvas.rotate(30f)

        canvas.translate(
            -(BITMAP_PADDING + BITMAP_SIZE / 2),
            -(BITMAP_PADDING + BITMAP_SIZE / 2))
        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING, paint)
        canvas.restore()

        // 下半部分
        canvas.translate (BITMAP_PADDING + BITMAP_SIZE / 2,
            BITMAP_PADDING + BITMAP_SIZE / 2)
        canvas.rotate(-30f)

        camera.applyToCanvas(canvas)
        canvas.clipRect(- BITMAP_SIZE, 0f, BITMAP_SIZE, BITMAP_SIZE)
        canvas.rotate(30f)

        canvas.translate(
            -(BITMAP_PADDING + BITMAP_SIZE / 2),
            -(BITMAP_PADDING + BITMAP_SIZE / 2))
        canvas.drawBitmap(bitmap, BITMAP_PADDING, BITMAP_PADDING, paint)

    }

    private fun getAvatar(width: Int): Bitmap {
        val options = BitmapFactory.Options()
        options.inJustDecodeBounds = true
        BitmapFactory.decodeResource(resources, R.drawable.avatar_rengwuxian, options)
        options.inJustDecodeBounds = false
        options.inDensity = options.outWidth
        options.inTargetDensity = width
        return BitmapFactory.decodeResource(resources, R.drawable.avatar_rengwuxian, options)
    }

}
```

![image-20210824162040886](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824162040886.png)
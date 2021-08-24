---
title: '自定义view绘制03:文字的测量'
date: 2021-08-20 15:14:12
categories:
- Android
- 自定义view
tags:
- Android
- 自定义view
---

# 文字测量

<!-- more -->

绘制文字:drawText()

为什么文字很难居中：因为文字的绘制起点是它的左上角

文字的对齐点要横向纵向分开说

横向对齐点：不固定，根据配置来（居左/右/中都不一样` Paint.Align.CENTER/RIGHT/LEFT`）

纵向：<u>baseLinep</u>，也就是文字下面视觉上的<u>对齐线（下划线）</u>

## 文字测量难点之一：居中的纵向测量

横向 ：`textAlign = Paint.Align.CENTER`

但是baseline的存在让文字纵向会稍显上移，修正方法：

**方式一:**

`Paint.getTextBounds() `（获得文字左上右下的边界值是多少)之后，纵坐标减去一个中心点到baseline的偏移 `(bounds.top + bounds.bottom) / 2`即可，

这种方法适合静态文字，因为因为有些文字比如字母p是会超过baseline的，这种方式在动态文字中使用可能导致图像跳动

**方式二:**

`Paint.getFontMetrics() `之后，使用` (fontMetrics.ascend + fontMetrics.descend) / 2`

指定一个不变的上下基准线来坐居中，更适合动态的文字使用，因为有些文字会超过baseline

除了baseline ，文字还有几种基准线，大多数汉字主体都在ascent和descent之间，所以我妈可以用这两个值获得纵坐标偏移量

我们只要计算字体的大小就可以了与数输入的文字内容,

这种方法适合动态文字，因为文字的显示稍微偏下

![image-20210821092551204](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210821092551204.png)

Eg:

```kotlin
package com.hencoder.customviewdrawing.text

import android.content.Context
import android.graphics.*
import android.os.Build
import android.util.AttributeSet
import android.view.View
import androidx.annotation.RequiresApi
import androidx.core.content.res.ResourcesCompat
import com.hencoder.customviewdrawing.R
import com.hencoder.customviewdrawing.view.dp


private val CIRCLE_COLOR = Color.parseColor("#90A4AE")
private val HIGHLIGHT_COLOR = Color.parseColor("#FF4081")
private val RING_WIDTH = 20.dp
private val RADIUS = 150.dp
private val bounds = Rect()
private val fontMetrics = Paint.FontMetrics()

class SportView(context: Context, attrs: AttributeSet?) :
  View(context, attrs) {
  private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
    textSize = 100.dp
    typeface = ResourcesCompat.getFont(context, R.font.font)
    // 不是真的BoldFont而是把细的字体描粗了
    isFakeBoldText
    //居中绘制
    textAlign = Paint.Align.CENTER

  }


  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  override fun onDraw(canvas: Canvas) {
    super.onDraw(canvas)

    // 绘制环
    paint.style = Paint.Style.STROKE
    paint.color = CIRCLE_COLOR
    paint.strokeWidth = RING_WIDTH
    canvas.drawCircle(width / 2f, height / 2f, RADIUS, paint)

    // 绘制进度条
    paint.color = HIGHLIGHT_COLOR
    // 绘制线的头部是圆形还是方形可以设置
    paint.strokeCap = Paint.Cap.ROUND
    canvas.drawArc(width / 2f - RADIUS, height / 2f - RADIUS, width / 2f + RADIUS, height / 2f + RADIUS, -90f, 225f, false, paint)
    paint.style = Paint.Style.FILL

    //绘制文字 居中（纵向）
    paint.textSize = 100.dp

    // 居中方法1 适合静态文字
//    paint.getTextBounds("abab",0,"abab".length,bounds )
//    canvas.drawText("abab",width/2f,height/2f- (bounds.top  + bounds.bottom)/2f,paint)
    // 居中方法2 适合动态文字
    paint.getFontMetrics(fontMetrics)
    canvas.drawText("apap",width/2f,height/2f- (fontMetrics.ascent+ fontMetrics.descent)/2f,paint)

    // 绘制文字 对齐：

    // 顶对齐
    paint.textSize = 15.dp
    paint.textAlign = Paint.Align.LEFT

    // 推荐使用fontMetrics.top计算 文字小时视觉效果好,
    // bounds.top 贴的过于紧密，fontMetrics.ascent线是固定的可能造成裁切
//    paint.getFontMetrics(fontMetrics)
//    canvas.drawText("abab",0f, fontMetrics.top,paint)

    paint.getTextBounds("abab",0,"abab".length,bounds)
    canvas.drawText("abab",-bounds.left.toFloat(),-bounds.top.toFloat(),paint)



    // 左对齐
    // 字不会完全贴在左/右，因为文字有自带的空隙
    // 若上下两行文字相差很大就会很明显
    // 但是受限与系统字体等因素仍可能有缝隙
    paint.textSize = 150.dp
    paint.textAlign = Paint.Align.LEFT
    paint.getTextBounds("abab",0,"abab".length,bounds)
    canvas.drawText("abab",-bounds.left.toFloat(),-bounds.top.toFloat(),paint)


  }
}
```



## 文字测量难点之二：对齐 

顶对齐

```kotlin
paint.getFontMetrics(fontMetrics)
paint.getTextBounds("abab",0,"abab".length,bounds)
// 推荐使用fontMetrics.top计算 文字小时视觉效果好,bounds.top 贴的过于紧密，fontMetrics.ascent线是固定的可能造成裁切
canvas.drawText("abab",0f,-fontMetrics.top,paint)
```

左对齐

字不会完全贴在左/右，因为文字有自带的空隙，若上下两行文字相差很大就会很明显，

需要用用 getTextBounds() 之后的 left 来计算

```kotlin

    // 左对齐
    // 字不会完全贴在左/右，因为文字有自带的空隙
    // 若上下两行文字相差很大就会很明显
    // 但是受限与系统字体等因素仍可能有缝隙
    paint.textSize = 150.dp
    paint.textAlign = Paint.Align.LEFT
    paint.getTextBounds("abab",0,"abab".length,bounds)
    canvas.drawText("abab",-bounds.left.toFloat(),-bounds.top.toFloat(),paint)
```



## 文字测量难点之三:换行

图文混排换行

用 breakText() 来计算

![image-20210824110143478](https://gitee.com/laonaiping/blog-images/raw/master/img/image-20210824110143478.png)

Eg:

```kotlin
package com.hencoder.customviewdrawing.text

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.AttributeSet
import android.view.View
import com.hencoder.customviewdrawing.R
import com.hencoder.customviewdrawing.view.dp

/**
 * Created by amazingZZ on 8/23/21
 */
private val IMAGE_SIZE = 150.dp
private val IMAGE_PADDING = 50.dp
class MultilineTextView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {
    // Lorem ipsum 无版权无意义文字
    val text =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur tristique urna tincidunt maximus viverra. Maecenas commodo pellentesque dolor ultrices porttitor. Vestibulum in arcu rhoncus, maximus ligula vel, consequat sem. Maecenas a quam libero. Praesent hendrerit ex lacus, ac feugiat nibh interdum et. Vestibulum in gravida neque. Morbi maximus scelerisque odio, vel pellentesque purus ultrices quis. Praesent eu turpis et metus venenatis maximus blandit sed magna. Sed imperdiet est semper urna laoreet congue. Praesent mattis magna sed est accumsan posuere. Morbi lobortis fermentum fringilla. Fusce sed ex tempus, venenatis odio ac, tempor metus."
    private val bitmap = getAvatar(IMAGE_SIZE.toInt())

    private val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
        textSize = 16.dp
    }
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        textSize = 16.dp
    }
    private  val fontMetrics = Paint.FontMetrics()
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        //args  文字， 文字画笔，宽度（有宽度才能换行），对齐方式，文字间距额外比例，文字间的间距额外值，是否需要额外行间距
//        val staticLayout =
//            StaticLayout(text, textPaint, width, Layout.Alignment.ALIGN_NORMAL, 1f, 0f, false)
//        staticLayout.draw(canvas)

        canvas.drawBitmap(bitmap, width - IMAGE_SIZE, IMAGE_PADDING, paint)
        paint.getFontMetrics(fontMetrics)

        // 可见宽度
        val measuredWidth = floatArrayOf(0f)
        //开始的字节
        var start = 0
        //切掉的文字index
        var count: Int
        var verticalOffset = - fontMetrics.top
        var maxWidth: Float

        while (start< text.length){
            maxWidth = if (verticalOffset+fontMetrics.bottom< IMAGE_PADDING||
                verticalOffset+fontMetrics.top> IMAGE_PADDING+ IMAGE_SIZE ){
                width.toFloat()
            }else {
                width.toFloat() - IMAGE_SIZE
            }

            // 换行 args ：文字，起始index，end index,是否是向前测量的， 宽度，测量文字实际显示宽度（边缘可能放不下一个字符）
            // 返回值：count:切掉掉文字index
            count =  paint.breakText(text,start,text.length,true,maxWidth,measuredWidth)
            canvas.drawText(text, start, start + count, 0f, verticalOffset, paint)
            start += count
            verticalOffset += paint.fontSpacing
        }

    }

    fun getAvatar(width: Int): Bitmap {
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


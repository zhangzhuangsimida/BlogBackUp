---
title: 自定义view绘制02-Xfermode
date: 2021-08-17 12:10:56
categories:
- Android
- 自定义view
tags:
- Android
- 自定义view
---

# Xfermode完全使用解析

为什么要 Xfermode?为了把多次绘制进行「合成」，例如蒙版效果:用 A 的形状和 B 的图案

怎么做?

1. Canvas.saveLayer() 把绘制区域拉到单独的离屏缓冲里
2. 绘制 A 图形
3. 用 Paint.setXfermode() 设置 Xfermode
4. 绘制 B 图形
5. 用 Paint.setXfermode(null) 恢复 Xfermode
6. 用 Canvas.restoreToCount() 把离屏缓冲中的合成后的图形放回绘制区域

```kotlin
private val IMAGE_WIDTH = 200f.px
private val IMAGE_PADDING = 20f.px
private val XFERMODE = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)

class AvatarView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {
    var paint = Paint(Paint.ANTI_ALIAS_FLAG)
    var bounds = RectF()

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        bounds.left = IMAGE_PADDING
        bounds.top = IMAGE_PADDING
        bounds.right = IMAGE_PADDING + IMAGE_WIDTH
        bounds.bottom = IMAGE_PADDING + IMAGE_WIDTH

    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        //  把绘制区域拉到单独的离屏缓冲里
        var count = canvas.saveLayer(bounds,null)
        // 绘制图形a
        canvas.drawOval(
            bounds,
            paint
        )
        // 设置 Xfermode，PorterDuff是创作者的名字，其他模式已经过时
        paint.xfermode = XFERMODE
        //绘制图形b
        canvas.drawBitmap(
            getAvatar(IMAGE_WIDTH.toInt()),
            IMAGE_PADDING, IMAGE_PADDING,
            paint
        )

        // 恢复 Xfermode
        paint.xfermode = null
        // 把离屏缓冲中的合成后的图形放回绘制区域 count 记录了绘制状态
        canvas.restoreToCount(count)
    }


    fun getAvatar(width: Int): Bitmap {
        // 利用option 可以提高读取bitmap的速度（只读取指定的大小）
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

为什么要用 saveLayer() 才能正确绘制 ?

为了把需要互相作用的图形放在单独的位置来绘制，不会受 View 本身的影响。 如果不使用 saveLayer()，绘制的目标区域将总是整个 View 的范围，两个图形 的交叉区域就错误了。

Ps

如果想做到像官网示例一样的效果，除了构建图形，还需要画出透明的bitmap底图

```kotlin
private val XFERMODE = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)


@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class XfermodeView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val bounds = RectF(150f.px, 50f.px, 300f.px, 200f.px)
    // 本来是100dp 为了符合官方文档，增加50dp作为底部画布，
    // 合成并不仅仅是所画的图形，透明的部分也会参与合成
    private val circleBitmap = Bitmap.createBitmap(150f.px.toInt(), 150f.px.toInt(), Bitmap.Config.ARGB_8888)
    private val squareBitmap = Bitmap.createBitmap(150f.px.toInt(), 150f.px.toInt(), Bitmap.Config.ARGB_8888)

    init {
        val canvas = Canvas(circleBitmap)
        paint.color = Color.parseColor("#D81B60")
        canvas.drawOval(50f.px, 0f.px, 150f.px, 100f.px, paint)
        paint.color = Color.parseColor("#2196F3")
        canvas.setBitmap(squareBitmap)
        canvas.drawRect(0f.px, 50f.px, 100f.px, 150f.px, paint)
    }

    override fun onDraw(canvas: Canvas) {
        val count = canvas.saveLayer(bounds, null)
        canvas.drawBitmap(circleBitmap, 150f.px, 50f.px, paint)
        paint.xfermode = XFERMODE
        canvas.drawBitmap(squareBitmap, 150f.px, 50f.px, paint)
        paint.xfermode = null
        canvas.restoreToCount(count)
    }

}
```


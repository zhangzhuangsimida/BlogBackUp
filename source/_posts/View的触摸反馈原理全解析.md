---
title: View的触摸反馈原理全解析
date: 2021-10-08 14:49:26
categories:
- Android
- view触摸反馈
tags:
- Android
- view触摸反馈
---

# View的触摸反馈原理全解析

## 自定义单 View 的触摸反馈

<img src="https://gitee.com/laonaiping/blog-images/raw/master/img/image-20211010105327764.png" alt="image-20211010105327764" style="zoom:50%;" />

1. 重写 onTouchEvent()，在方法内部定制触摸反馈算法

   1. 是否消费事件取决于 ACTION_DOWN 事件是否返回 true

   2. MotionEvent

      - getActionMasked() 和 getAction() 怎么选?

        选 getActionMasked()。因为到了多点触控时代，getAction() 已经不够准确

        ```kotlin
                // 在Android增加多点触控的机制后
        				// MotionEvent除了包含触摸状态也包含了多点触控信息
                // 所以判断时事件时actionMasked最合适
                // 触摸事件
                MotionEvent.ACTION_UP
                MotionEvent.ACTION_DOWN
                MotionEvent.ACTION_CANCEL
                MotionEvent.ACTION_MOVE
                // 多点触控， +1 ，+2 表示第几根手指触碰
                MotionEvent.ACTION_POINTER_DOWN
                MotionEvent.ACTION_POINTER_UP
        ```
   
        
   
      - 那为什么有些地方(包括 Android 源码里)依然在用 getAction()? 
   
        因为它们的场景不考虑多点触控
   
   3. POINTER_DOWN / POINTER_UP:多点触控时的事件
   
      - getActionIndex():多点触控时用到的方法
   
        

## View.onTouchEvent() 的源码逻辑

1. 当用户按下(ACTION_DOWN):

   - 如果不在滑动控件中，切换至按下状态，并注册⻓按计时器
   - 如果在滑动控件中，切换至预按下状态，并注册按下计时器

2. 当进入按下状态并移动(ACTION_MOVE):

   - 重绘 Ripple Effect

   - 如果移动出自己的范围，自我标记本次事件失效，忽略后续事件

3. 当用户抬起(ACTION_UP):

   - 如果是按下状态并且未触发⻓按，切换至抬起状态并触发点击事件，并清除一切状态
   - 如果已经触发⻓按，切换至抬起状态并清除一切状态

4. 当事件意外结束(ACTION_CANCEL):

   - 切换至抬起状态，并清除一切状态


> Tool Tip:新版 Android 加入的「⻓按提示」功能。

```java
    public boolean onTouchEvent(MotionEvent event) {
        final float x = event.getX();
        final float y = event.getY();
        final int viewFlags = mViewFlags;
        final int action = event.getAction();

        final boolean clickable = ((viewFlags & CLICKABLE) == CLICKABLE
                || (viewFlags & LONG_CLICKABLE) == LONG_CLICKABLE)
                || (viewFlags & CONTEXT_CLICKABLE) == CONTEXT_CLICKABLE;

        if ((viewFlags & ENABLED_MASK) == DISABLED) {
            if (action == MotionEvent.ACTION_UP && (mPrivateFlags & PFLAG_PRESSED) != 0) {
                setPressed(false);
            }
            mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
            // A disabled view that is clickable still consumes the touch
            // events, it just doesn't respond to them.
            return clickable;
        }
        if (mTouchDelegate != null) {
            if (mTouchDelegate.onTouchEvent(event)) {
                return true;
            }
        }

        if (clickable || (viewFlags & TOOLTIP) == TOOLTIP) {
            switch (action) {
                case MotionEvent.ACTION_UP:
                    mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
                    if ((viewFlags & TOOLTIP) == TOOLTIP) {
                        handleTooltipUp();
                    }
                    if (!clickable) {
                        removeTapCallback();
                        removeLongPressCallback();
                        mInContextButtonPress = false;
                        mHasPerformedLongPress = false;
                        mIgnoreNextUpEvent = false;
                        break;
                    }
                    boolean prepressed = (mPrivateFlags & PFLAG_PREPRESSED) != 0;
                    if ((mPrivateFlags & PFLAG_PRESSED) != 0 || prepressed) {
                        // take focus if we don't have it already and we should in
                        // touch mode.
                        boolean focusTaken = false;
                        if (isFocusable() && isFocusableInTouchMode() && !isFocused()) {
                            focusTaken = requestFocus();
                        }

                        if (prepressed) {
                            // The button is being released before we actually
                            // showed it as pressed.  Make it show the pressed
                            // state now (before scheduling the click) to ensure
                            // the user sees it.
                            setPressed(true, x, y);
                        }

                        if (!mHasPerformedLongPress && !mIgnoreNextUpEvent) {
                            // This is a tap, so remove the longpress check
                            removeLongPressCallback();

                            // Only perform take click actions if we were in the pressed state
                            if (!focusTaken) {
                                // Use a Runnable and post this rather than calling
                                // performClick directly. This lets other visual state
                                // of the view update before click actions start.
                                if (mPerformClick == null) {
                                    mPerformClick = new PerformClick();
                                }
                                if (!post(mPerformClick)) {
                                    performClickInternal();
                                }
                            }
                        }

                        if (mUnsetPressedState == null) {
                            mUnsetPressedState = new UnsetPressedState();
                        }

                        if (prepressed) {
                            postDelayed(mUnsetPressedState,
                                    ViewConfiguration.getPressedStateDuration());
                        } else if (!post(mUnsetPressedState)) {
                            // If the post failed, unpress right now
                            mUnsetPressedState.run();
                        }

                        removeTapCallback();
                    }
                    mIgnoreNextUpEvent = false;
                    break;

                case MotionEvent.ACTION_DOWN:
                    if (event.getSource() == InputDevice.SOURCE_TOUCHSCREEN) {
                        mPrivateFlags3 |= PFLAG3_FINGER_DOWN;
                    }
                    mHasPerformedLongPress = false;

                    if (!clickable) {
                        checkForLongClick(
                                ViewConfiguration.getLongPressTimeout(),
                                x,
                                y,
                                TOUCH_GESTURE_CLASSIFIED__CLASSIFICATION__LONG_PRESS);
                        break;
                    }

                    if (performButtonActionOnTouchDown(event)) {
                        break;
                    }

                    // Walk up the hierarchy to determine if we're inside a scrolling container.
                    boolean isInScrollingContainer = isInScrollingContainer();

                    // For views inside a scrolling container, delay the pressed feedback for
                    // a short period in case this is a scroll.
                    if (isInScrollingContainer) {
                        mPrivateFlags |= PFLAG_PREPRESSED;
                        if (mPendingCheckForTap == null) {
                            mPendingCheckForTap = new CheckForTap();
                        }
                        mPendingCheckForTap.x = event.getX();
                        mPendingCheckForTap.y = event.getY();
                        postDelayed(mPendingCheckForTap, ViewConfiguration.getTapTimeout());
                    } else {
                        // Not inside a scrolling container, so show the feedback right away
                        setPressed(true, x, y);
                        checkForLongClick(
                                ViewConfiguration.getLongPressTimeout(),
                                x,
                                y,
                                TOUCH_GESTURE_CLASSIFIED__CLASSIFICATION__LONG_PRESS);
                    }
                    break;

                case MotionEvent.ACTION_CANCEL:
                    if (clickable) {
                        setPressed(false);
                    }
                    removeTapCallback();
                    removeLongPressCallback();
                    mInContextButtonPress = false;
                    mHasPerformedLongPress = false;
                    mIgnoreNextUpEvent = false;
                    mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
                    break;

                case MotionEvent.ACTION_MOVE:
                    if (clickable) {
                        drawableHotspotChanged(x, y);
                    }

                    final int motionClassification = event.getClassification();
                    final boolean ambiguousGesture =
                            motionClassification == MotionEvent.CLASSIFICATION_AMBIGUOUS_GESTURE;
                    int touchSlop = mTouchSlop;
                    if (ambiguousGesture && hasPendingLongPressCallback()) {
                        if (!pointInView(x, y, touchSlop)) {
                            // The default action here is to cancel long press. But instead, we
                            // just extend the timeout here, in case the classification
                            // stays ambiguous.
                            removeLongPressCallback();
                            long delay = (long) (ViewConfiguration.getLongPressTimeout()
                                    * mAmbiguousGestureMultiplier);
                            // Subtract the time already spent
                            delay -= event.getEventTime() - event.getDownTime();
                            checkForLongClick(
                                    delay,
                                    x,
                                    y,
                                    TOUCH_GESTURE_CLASSIFIED__CLASSIFICATION__LONG_PRESS);
                        }
                        touchSlop *= mAmbiguousGestureMultiplier;
                    }

                    // Be lenient about moving outside of buttons
                    if (!pointInView(x, y, touchSlop)) {
                        // Outside button
                        // Remove any future long press/tap checks
                        removeTapCallback();
                        removeLongPressCallback();
                        if ((mPrivateFlags & PFLAG_PRESSED) != 0) {
                            setPressed(false);
                        }
                        mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
                    }

                    final boolean deepPress =
                            motionClassification == MotionEvent.CLASSIFICATION_DEEP_PRESS;
                    if (deepPress && hasPendingLongPressCallback()) {
                        // process the long click action immediately
                        removeLongPressCallback();
                        checkForLongClick(
                                0 /* send immediately */,
                                x,
                                y,
                                TOUCH_GESTURE_CLASSIFIED__CLASSIFICATION__DEEP_PRESS);
                    }

                    break;
            }

            return true;
        }

        return false;
    }

```



## 自定义 ViewGroup 的触摸反馈

除了重写 onTouchEvent() ，还需要重写 onInterceptTouchEvent(), onInterceptTouchEvent() 不用在第一时间返回 true，而是在任意一个事件里， 需要拦截的时候返回 true 就行
 在 onInterceptTouchEvent() 中除了判断拦截，还要做好拦截之后的工作的准备工作(主要和 onTouchEvent() 的代码逻辑一致)

## 触摸反馈的流程

- Activity.dispatchTouchEvent()
  - 递归: ViewGroup(View).dispatchTouchEvent()
  - ViewGroup.onInterceptTouchEvent()
  - child.dispatchTouchEvent()
  - super.dispatchTouchEvent()
    - View.onTouchEvent()
  - Activity.onTouchEvent()

## View.dispatchTouchEvent()

- 如果设置了 OnTouchListener，调用 OnTouchListener.onTouch()
  - 如果 OnTouchListener 消费了事件，返回 true
  - 如果 OnTouchListener 没有消费事件，继续调用自己的 onTouchEvent()， 并返回和 onTouchEvent() 相同的结果
- 如果没有设置 OnTouchListener，同上

## ViewGroup.dispatchTouchEvent()

- 如果是用户初次按下(ACTION_DOWN)，清空 TouchTargets 和 DISALLOW_INTERCEPT 标记
- 拦截处理
- 如果不      拦截并且不是 CANCEL 事件，并且是 DOWN 者 POINTER_DOWN，尝 试把 pointer(手指)通过 TouchTarget 分配给子 View;并且如果分配给了新 的子 View，调用 child.dispatchTouchEvent() 把事件传给子 View
- 看有没有 TouchTarget
  - 如果没有，调用自己的 super.dispatchTouchEvent()
  - 如果有，调用 child.dispatchTouchEvent() 把事件传给对应的子 View(如果有的话)
- 如果是 POINTER_UP，从 TouchTargets 中清除 POINTER 信息;如果是 UP 或 CANCEL，重置状态

## TouchTarget

- 作用:记录每个子 View 是被哪些 pointer(手指)按下的
- 结构:单向链表

​                          -                                                                       

---
title: Html标签
date: 2021-07-15 05:49:56
categories:
- Html
tags:
- Html
---

# Html 标签



## Form 表单

放在Form内提交，简单使用：

```html
 <form action="https://tcc.taobao.com/cc/json/mobile_tel_segment.htm">
    <fieldset>
      <legend>测试</legend>
      <input type="text" name="tel">
    </fieldset>
    <button>提交</button>
  </form>
```

Input标签的name相当于Http 普通表单`ContentType : application/x-www-form-urlencode`）请（求的key，输入内容为普通表单的value ，也是Http 提交表单最原始的方式。

| 属性   | 说明                 |
| ------ | -------------------- |
| action | 后台地址             |
| method | 提交方式 GET 或 POST |

### LABEL

使用 `label` 用于描述表单标题，当点击标题后文本框会获得焦点，需要保证使用的ID在页面中是唯一的。

```html
<form action="https://tcc.taobao.com/cc/json/mobile_tel_segment.htm">
    <fieldset>
      <legend>测试</legend>
      <label >电话号码
      <input type="text"  name="tel"></label>
      <hr/>
      <label for="name">姓名</label>
      <input type="text" id="name" name="name">
    </fieldset>
    <button>提交</button>
  </form>
```

> 想在点击`abel`的时候让`input`获得焦点，要么用label标签包裹input ，要么让`input` 的`id`属性和`label`的`for`属性内容一致。

### INPUT

文本框用于输入单行文本使用，下面是常用属性与示例。

| 属性        | 说明                                                         |
| ----------- | ------------------------------------------------------------ |
| type        | 表单类型默认为 `text`                                        |
| name        | 后台接收字段名                                               |
| required    | 必须输入                                                     |
| placeholder | 提示文本内容                                                 |
| value       | 默认值                                                       |
| maxlength   | 允许最大输入字符数                                           |
| size        | 表单显示长度，一般用不使用而用 `css` 控制                    |
| disabled    | 禁止使用，不可以提交到后台                                   |
| readonly    | 只读，可提交到后台                                           |
| capture     | 使用麦克风、视频或摄像头哪种方式获取手机上传文件，支持的值有 microphone, video, camera |

约束示例：

```html
 <form action="https://tcc.taobao.com/cc/json/mobile_tel_segment.htm">
    <fieldset>
      <legend>测试</legend>
      <label>电话号码
        <input type="text" name="tel" required placeholder="输入手机号"></label>
      <hr />
      <label for="name">姓名</label>
      <input type="text" id="name" placeholder="输入姓名" name="name">
      <label>来源
        <input type="text" placeholder="输入姓名" name="source" value="后盾人"> </label>
    </fieldset>
    <button>提交</button>
  </form>
```

**调取摄像头**

当input类型为file时手机会让用户选择图片或者拍照，如果想直接调取摄像头使用以下代码。

```text
<input type="file" capture="camera" accept="image/*" />
```

其他类型

通过设置表单的 `type` 字段可以指定不同的输入内容。

| 类型     | 说明                         |
| -------- | ---------------------------- |
| email    | 输入内容为邮箱               |
| url      | 输入内容为URL地址            |
| password | 输入内容为密码项             |
| tel      | 电话号，移动端会调出数字键盘 |
| search   | 搜索框                       |
| hidden   | 隐藏表单                     |
| submit   | 提交表单                     |

### HIDDEN

隐藏表单用于提交后台数据，但在前台内容不显示所以在其上做用样式定义也没有意义。

```html
<input type="hidden" name="id" value="1">
```

### 提交表单

创建提交按钮可以将表单数据提交到后台，有多种方式可以提交数据如使用AJAX，或HTML的表单按钮。

1. 使用input构建提交按钮，如果设置了name值按钮数据也会提交到后台，如果有多个表单项可以通过些判断是哪个表单提交的。

   ```html
   <input type="submit" name="submit" value="提交表单">
   ```

2. 使用button也可以提交，设置type属性为`submit` 或不设置都可以提交表单。

   ```html
   <button type="submit">提交表单</button>
   ```

### 禁用表单

通过为表单设置 `disabled` 或 `readonly` 都可以禁止修改表单，但 `readonly`表单的数据可以提交到后台。

```html
<input type="text" name="web" value="houdunren.com" readonly>

```

### PATTERN

表单可以通过设置 `pattern` 属性指定正则验证，也可以使用各种前端验证库如 [formvalidator (opens new window)](http://www.formvalidator.net/#default-validators_custom)或 [validator.js (opens new window)](https://github.com/validatorjs/validator.js)。

| 属性      | 说明                 |
| --------- | -------------------- |
| pattern   | 正则表达式验证规则   |
| oninvalid | 输入错误时触发的事件 |

```html
<form action="">
	<input type="text" name="username" pattern="[A-z]{5,20}" 
	oninvalid="validate('请输入5~20位字母的用户名')">
	<button>提交</button>
</form>
    
<script>
	function validate(message) {
		alert(message);
	}
</script>
```

###  
---
title: 重新利用hexo和github page 建立了一个blog
categories:
- hexo
tags:
- hexo
  
---
## Hexo + GitHub Pages + Typora 构建博客 (1) Hexo 的安装

最近在学一些网络知识，但是使用市面上支持 [Markdown ](https://www.runoob.com/markdown/md-tutorial.html)的 笔记工具（如简书，有道云笔记，印象笔记）的产品，时常遇到两类问题：

1. 功能过于复杂（有道，印象），很多功能我用不上，且打开有些卡顿

2. 没有在线存储文件或者图片的能力（Typora）

3. 在线打开操作不够方便，体验不够好（简书，掘金）

4. 需要付费

因此我准备构建一套的博客工具，方案采用

 Hexo+Git Page +Typora，





```mermaid
graph TD
A[简易博客系统] --> B(Hexo 生成静态网页)
A --> C(Github Page Mini服务器)
A --> D(Typora Mini客户端 编辑文本)
E[简易博客系统]
```

<!--more-->


   ###  Hexo 构建博客静态页面

Hexo 是一个基于[nodejs](http://www.oschina.net/p/nodejs) 的静态博客网站生成器，作者是来自台湾的 [Tommy Chen](http://mailto:tommy351@gmail.com/)

#### 安装

建议直接阅读官网的文档 参考安装

https://hexo.io/zh-cn/   

```bash
 npm install hexo-cli -g
 hexo init blog
 cd blog
 npm install
 hexo server
```

（本文选择版本 hexo-cli: 4.2.0）

#### 常用命令

##### 清理缓存

```bash
 hexo clean
```

##### 创建文章

  ``` bash
   hexo new "My New Post"
   缩写版本
   hexo n "新文章title" 
  ```

More info: [Writing](https://hexo.io/docs/writing.html)

##### 本地调试

``` bash
 hexo server
 缩写版本
 hexo s
```

More info: [Server](https://hexo.io/docs/server.html)

##### 构建静态文件

``` bash
 hexo generate
 缩写版本
 hexo g
```

More info: [Generating](https://hexo.io/docs/generating.html)

##### 发布文章

``` bash
 hexo deploy
 缩写版本
 hexo d
```

More info: [Deployment](https://hexo.io/docs/one-command-deployment.html)

注意：发布之后的文章会覆盖之前发布的（全量发布），所以多终端发布之前先 同步好博客资源。

生成资源+发布的操作可以简化为

```bash
 hexo g -d
```

##### 文章标签和分类

参考官方文档：https://hexo.io/zh-cn/docs/front-matter

只有文章支持分类和标签，您可以在 Front-matter 中设置。在其他系统中，分类和标签听起来很接近，但是在 Hexo 中两者有着明显的差别：分类具有顺序性和层次性，也就是说 `Foo, Bar` 不等于 `Bar, Foo`；而标签没有顺序和层次。

```baash
categories:
- Diary
tags:
- PS3
- Games
```

#### 使用个性化主题NexT

是用了NexT主题

##### NexT主题安装

安装建议参考官方文档：http://theme-next.iissnan.com/

但是官方镜像（Github 仓库）下载过于慢了，最终我采用的是下载Gitee上的镜像（也可以将官方镜像导入自己的Gitee仓库）

```bash
cd blog
git clone git@gitee.com:Lee-Li/hexo-theme-next.git themes/next
```

##### 启用主题

与所有 Hexo 主题启用的模式一样。 当 克隆/下载 完成后，打开 `blog/_config.yml `， 找到 `theme` 字段，并将其值更改为 `next`。

启用 NexT 主题

```
theme: next
```

到此，NexT 主题安装完成。下一步我们将验证主题是否正确启用。在切换主题之后、验证之前， 我们最好使用 `hexo clean` 来清除 Hexo 的缓存。

##### 主题设定

###### 选择 Scheme

Scheme 是 NexT 提供的一种特性，借助于 Scheme，NexT 为你提供多种不同的外观。同时，几乎所有的配置都可以 在 Scheme 之间共用。目前 NexT 支持三种 Scheme，他们是：

- Muse - 默认 Scheme，这是 NexT 最初的版本，黑白主调，大量留白
- Mist - Muse 的紧凑版本，整洁有序的单栏外观
- Pisces - 双栏 Scheme，小家碧玉似的清新

Scheme 的切换通过更改 **主题配置文件**，搜索 scheme 关键字。 你会看到有三行 scheme 的配置，将你需用启用的 scheme 前面注释 `#` 去除即可。

选择 Pisces Scheme

```
#scheme: Muse
#scheme: Mist
scheme: Pisces
```

##### 设置 语言

编辑 **站点配置文件**， 将 `language` 设置成你所需要的语言。建议明确设置你所需要的语言，例如选用简体中文，配置如下：

```
language: zh-Hans
```

目前 NexT 支持的语言如以下表格所示：

| 语言         | 代码                 | 设定示例                            |
| :----------- | :------------------- | :---------------------------------- |
| English      | `en`                 | `language: en`                      |
| 简体中文     | `zh-Hans`            | `language: zh-Hans`                 |
| Français     | `fr-FR`              | `language: fr-FR`                   |
| Português    | `pt`                 | `language: pt` or `language: pt-BR` |
| 繁體中文     | `zh-hk` 或者 `zh-tw` | `language: zh-hk`                   |
| Русский язык | `ru`                 | `language: ru`                      |
| Deutsch      | `de`                 | `language: de`                      |
| 日本語       | `ja`                 | `language: ja`                      |
| Indonesian   | `id`                 | `language: id`                      |
| Korean       | `ko`                 | `language: ko`                      |

##### 设置 菜单

菜单配置包括三个部分，第一是菜单项（名称和链接），第二是菜单项的显示文本，第三是菜单项对应的图标。 NexT 使用的是 [Font Awesome](http://fontawesome.io/) 提供的图标， Font Awesome 提供了 600+ 的图标，可以满足绝大的多数的场景，同时无须担心在 Retina 屏幕下 图标模糊的问题。

编辑 **主题配置文件**，修改以下内容：

1. 设定菜单内容，对应的字段是 `menu`。 菜单内容的设置格式是：`item name: link`。其中 `item name `是一个名称，这个名称并不直接显示在页面上，她将用于匹配图标以及翻译。

   菜单示例配置

   ```
   menu:
     home: /
     archives: /archives
     #about: /about
     #categories: /categories
     tags: /tags
     #commonweal: /404.html
   ```

##### 配置标签、分类、公益404页面

请参考 官方文档 ：http://theme-next.iissnan.com/theme-settings.html

##### 添加「标签」页面

1. 新建页面：在终端窗口下，定位到 Hexo 站点目录下。使用 `hexo new page` 新建一个页面，命名为 `categories` ：
  ```
  $ cd your-hexo-site
  $ hexo new page categories
  ```

2. 设置页面类型：编辑刚新建的页面，将页面的 `type` 设置为 `categories` ，主题将自动为这个页面显示分类。页面内容如下：

   ```
   title: 分类
   date: 2014-12-22 12:39:04
   type: "categories"
   ---
   ```

3. 修改菜单

   在菜单中添加链接。编辑 **主题配置文件** ， 添加 `categories` 到 `menu` 中，如下:

   ```
   menu:
     home: /
     archives: /archives
     categories: /categories
   ```

   

**注意：**如果有集成评论服务，页面也会带有评论。 若需要关闭的话，请添加字段 `comments` 并将值设置为 `false`，如：
禁用评论示例

```
title: 标签
date: 2014-12-22 12:39:04
type: "tags"
comments: false
---
```

##### 添加「分类」页面

新建「分类」页面，并在菜单中显示「分类」链接。「分类」页面将展示站点的所有分类，若你的所有文章都未包含分类，此页面将是空的。 底下代码是一篇包含分类的文章的例子：

```
title: 分类测试文章
categories: Testing
---
```

请参阅 [Hexo 的分类与标签文档](https://hexo.io/zh-cn/docs/front-matter.html#分类和标签)，了解如何为文章添加标签或者分类。

1. 新建页面：在终端窗口下，定位到 Hexo 站点目录下。使用 `hexo new page` 新建一个页面，命名为 `categories` ：

   ```
    cd your-hexo-site
    hexo new page categories
   ```

2. 设置页面类型：编辑刚新建的页面，将页面的 `type` 设置为 `categories` ，主题将自动为这个页面显示分类。页面内容如下：

  ```
  title: 分类
  date: 2014-12-22 12:39:04
  type: "categories"
  ---
  ```

3. 修改菜单在菜单中添加链接。编辑 **主题配置文件** ， 添加 `categories` 到 `menu` 中，如下:

   ```
    menu:
      home: /
      archives: /archives
      categories: /categories
   ```

**注意：**如果有集成评论服务，页面也会带有评论。 若需要关闭的话，请添加字段 `comments` 并将值设置为 `false`，如：

   禁用评论示例

   ```
   title: 分类
   date: 2014-12-22 12:39:04
   type: "categories"
   comments: false
   ---
   ```
##### 主题配置文件是什么
> ##### **主题配置文件**指的是theme/next下面的_config.yml文件

### 问题汇总

#### hexo 本地图片无法加载

放在 和文章同名的文件夹下，执行`hexo g` 生成静态Html文件的时候，img标签的路径总是指向错误的方式

**解决方案：**

asset-image 插件

在 hexo 2.x 时出现的插件，后来被吸纳进 hexo 3 core。比较尴尬的是，这种方法直接放弃了 markdown 原来的语法，使用类似 的语法，。markdown 本来有插入图片的语法不好好支持，专门用一个新的语法来插入本地图片。

解决方案： [hexo-asset-image插件](https://github.com/CodeFalling/hexo-asset-image)

首先修改_config.yml文件里面的

```
post_asset_folder: true
```

然后再hexo目录执行

```
npm install https://github.com/CodeFalling/hexo-asset-image --save
```

#### Hexo Next Theme 不支持mermaid流程图

```bash
npm install hexo-filter-mermaid-diagrams --save 
```

打开theme/next/_config.xml

然后搜索关键字mermaid，如果是false，就把它改成true，如果是true，就可以不用修改了



> 参考文章:
>
> [hexo如何加入本地图片：hexo](https://www.dazhuanlan.com/2020/01/06/5e1292fd8e5b9/)
>
> [使用 Github Pages 和 Hexo 搭建自己的独立博客【超级详细的小白教程】](https://blog.csdn.net/qq_36759224/article/details/82121420)
>
> [用Typora写Hexo博客](https://www.jianshu.com/p/053374fe219f)
>
> [hexo next渲染markdown mermaid流程图](https://jingyan.baidu.com/article/e75aca85a3b528552fdac670.html)


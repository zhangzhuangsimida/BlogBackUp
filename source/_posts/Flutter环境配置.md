---
title: Flutter环境配置
date: 2021-07-16 09:59:35
categories:
- Flutter
tags:
- Flutter
---

# Flutter环境配置

## macOS环境配置

https://flutterchina.club/setup-macos/

### 系统要求：

要安装并运行Flutter，您的开发环境必须满足以下最低要求:

- **操作系统**: macOS (64-bit)

- **磁盘空间**: 700 MB (不包括Xcode或Android Studio的磁盘空间）.

- 工具

  : Flutter 依赖下面这些命令行工具.

  - `bash`, `mkdir`, `rm`, `git`, `curl`, `unzip`, `which`



### 设置Flutter 镜像

由于在国内访问Flutter有时可能会受到限制，Flutter官方为中国开发者搭建了临时镜像，大家可以将如下环境变量加入到用户环境变量中：

```
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

**注意：** 此镜像为临时镜像，并不能保证一直可用，读者可以参考详情请参考 [Using Flutter in China](https://github.com/flutter/flutter/wiki/Using-Flutter-in-China) 以获得有关镜像服务器的最新动态。

**Mac ：环境变量配置文件**`open .bash_profile`

**常见问题:**Mac 每次都要执行`source ~/.bash_profile `配置的环境变量才生效自己在 `~/.bash_profile `中配置环境变量, 可是每次重启终端后配置的不生效.需要重新执行 :` $source ~/.bash_profile`

发现zsh加载的是 `~/.zshrc`文件，而`‘.zshrc`文件中并没有定义任务环境变量。

解决办法:在~/.zshrc文件最后，增加一行：

```
source ~/.bash_profile
```

### 获得FlutterSDK

1. 去flutter官网下载其最新可用的安装包，[转到下载页](https://flutter.io/sdk-archive/#macos) 。

   注意，Flutter的渠道版本会不停变动，请以Flutter官网为准。另外，在中国大陆地区，要想正常获取安装包列表或下载安装包，可能需要翻墙，读者也可以去Flutter github项目下去下载安装包，[转到下载页](https://github.com/flutter/flutter/releases) 。

   推荐使用Stable channel 稳定版本

2. 解压安装包到你想安装的目录，如：

   ```shell
   cd ~/development
   unzip ~/Downloads/flutter_macos_v0.5.1-beta.zip
   ```

3. 添加`flutter`相关工具到path中：

   ```shell
   export PATH=`pwd`/flutter/bin:$PATH
   ```

   此代码只能暂时针对当前命令行窗口设置PATH环境变量，要想永久将Flutter添加到PATH中请参考下面**更新环境变量** 部分

   ```
   注意： 由于一些flutter命令需要联网获取数据，如果您是在国内访问，由于众所周知的原因，直接访问很可能不会成功。 上面的PUB_HOSTED_URL和FLUTTER_STORAGE_BASE_URL是google为国内开发者搭建的临时镜像。详情请参考 Using Flutter in China
   ```

   要更新现有版本的Flutter，请参阅[升级Flutter](https://flutterchina.club/upgrading/)。

### IOS环境配置

要为iOS开发Flutter应用程序，您需要Xcode 7.2或更高版本:

1. 安装Xcode 7.2或更新版本(通过[链接下载](https://developer.apple.com/xcode/)或[苹果应用商店](https://itunes.apple.com/us/app/xcode/id497799835)).

2. 配置Xcode命令行工具以使用新安装的Xcode版本 

   `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` 

3. 确保Xcode许可协议是通过打开一次Xcode或通过命令`sudo xcodebuild -license`同意过了.

### 设置iOS模拟器

要准备在iOS模拟器上运行并测试您的Flutter应用，请按以下步骤操作：

1. 在Mac上，通过Spotlight或使用以下命令找到模拟器:

   ```commandline
   open -a Simulator
   ```

2. 通过检查模拟器 **硬件>设备** 菜单中的设置，确保您的模拟器正在使用64位设备（iPhone 5s或更高版本）.

3. 根据您的开发机器的屏幕大小，模拟的高清屏iOS设备可能会使您的屏幕溢出。在模拟器的 **Window> Scale** 菜单下设置设备比例

4. 创建一个项目`flutter create my_flutter`

5. 运行 `flutter run`启动您的应用.

### 安装到iOS设备

要将您的Flutter应用安装到iOS真机设备，您需要一些额外的工具和一个Apple帐户，您还需要在Xcode中进行设置。

1. 安装 [homebrew](http://brew.sh/) （如果已经安装了brew,跳过此步骤）.

2. 打开终端并运行这些命令来安装用于将Flutter应用安装到iOS设备的工具

   ```commandline
   brew update
   brew install --HEAD libimobiledevice
   brew install ideviceinstaller ios-deploy cocoapods
   pod setup
   ```

如果这些命令中的任何一个失败并出现错误，请运行brew doctor并按照说明解决问题.

1. 遵循Xcode签名流程来配置您的项目:

   1. 在你Flutter项目目录中通过 `open ios/Runner.xcworkspace` 打开默认的Xcode workspace.

   2. 在Xcode中，选择导航面板左侧中的`Runner`项目

   3. 在`Runner` target设置页面中，确保在 **常规>签名>团队** 下选择了您的开发团队。当您选择一个团队时，Xcode会创建并下载开发证书，向您的设备注册您的帐户，并创建和下载配置文件（如果需要）

      - 要开始您的第一个iOS开发项目，您可能需要使用您的Apple ID登录Xcode.
        ![Xcode account add](https://flutterchina.club/images/setup/xcode-account.png)
        任何Apple ID都支持开发和测试。需要注册Apple开发者计划才能将您的应用分发到App Store. 查看[differences between Apple membership types](https://developer.apple.com/support/compare-memberships).

      - 当您第一次attach真机设备进行iOS开发时，您需要同时信任你的Mac和该设备上的开发证书。首次将iOS设备连接到Mac时,请在对话框中选择 `Trust`。

        ![Trust Mac](https://flutterchina.club/images/setup/trust-computer.png)

        然后，转到iOS设备上的设置应用程序，选择 **常规>设备管理** 并信任您的证书。

      - 如果Xcode中的自动签名失败，请验证项目的 **General > Identity > Bundle Identifier** 值是否唯一.

      ![Check the app's Bundle ID](https://flutterchina.club/images/setup/xcode-unique-bundle-id.png)

2. 运行启动您的应用程序 `flutter run`.

## Android设置

### 安装Android Studio

要为Android开发Flutter应用，您可以使用Mac，Windows或Linux（64位）机器.

Flutter需要安装和配置Android Studio:

1. 下载并安装 [Android Studio](https://developer.android.com/studio/index.html).
2. 启动Android Studio，然后执行“Android Studio安装向导”。这将安装最新的Android SDK，Android SDK平台工具和Android SDK构建工具，这是Flutter为Android开发时所必需的

### 设置您的Android设备

要准备在Android设备上运行并测试您的Flutter应用，您需要安装Android 4.1（API level 16）或更高版本的Android设备.

1. 在您的设备上启用 **开发人员选项** 和 **USB调试** 。详细说明可在[Android文档](https://developer.android.com/studio/debug/dev-options.html)中找到。
2. 使用USB将手机插入电脑。如果您的设备出现提示，请授权您的计算机访问您的设备。
3. 在终端中，运行 `flutter devices` 命令以验证Flutter识别您连接的Android设备。
4. 运行启动您的应用程序 `flutter run`。

默认情况下，Flutter使用的Android SDK版本是基于你的 `adb` 工具版本。 如果您想让Flutter使用不同版本的Android SDK，则必须将该 `ANDROID_HOME` 环境变量设置为SDK安装目录。

### 设置Android模拟器

要准备在Android模拟器上运行并测试您的Flutter应用，请按照以下步骤操作：

1. 在您的机器上启用 [VM acceleration](https://developer.android.com/studio/run/emulator-acceleration.html) .

2. 启动 **Android Studio>Tools>Android>AVD Manager** 并选择 **Create Virtual Device**.

3. 选择一个设备并选择 **Next**。

4. 为要模拟的Android版本选择一个或多个系统映像，然后选择 **Next**. 建议使用 *x86* 或 *x86_64* image .

5. 在 Emulated Performance下, 选择 **Hardware - GLES 2.0** 以启用 [硬件加速](https://developer.android.com/studio/run/emulator-acceleration.html).

6. 验证AVD配置是否正确，然后选择 **Finish**。

   有关上述步骤的详细信息，请参阅 [Managing AVDs](https://developer.android.com/studio/run/managing-avds.html).

7. 在 Android Virtual Device Manager中, 点击工具栏的 **Run**。模拟器启动并显示所选操作系统版本或设备的启动画面.

8. 运行 `flutter run` 启动您的设备. 连接的设备名是 `Android SDK built for <platform>`,其中 *platform* 是芯片系列, 如 x86.
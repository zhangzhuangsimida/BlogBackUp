---
title: adb相关
date: 2021-04-12 19:17:49
categories:
- adb
tags:
- adb
---
# adb相关问题
<!-- more -->

## Mac OS 部分机型adb不识别

1. 终端输入指令` system_profiler SPUSBDataType`拿到vid 即Vendor ID 即：0x18d1

```bash
$ system_profiler SPUSBDataType
USB:

  ...

          Product ID: 0x2817
          Vendor ID: 0x2109  (VIA Labs, Inc.)
          Version: 3.d3
          Speed: Up to 480 Mb/sec
          Manufacturer: VIA Labs, Inc.
          Location ID: 0x14100000 / 25
          Current Available (mA): 500
          Current Required (mA): 0
          Extra Operating Current (mA): 0

            Spreadtrum Phone:

              Product ID: 0x4ee7
              Vendor ID: 0x18d1  (Google Inc.)
              Version: 4.04
              Serial Number: 19254464082042
              Speed: Up to 480 Mb/sec
              Manufacturer: Spreadtrum
              Location ID: 0x14140000 / 35
              Current Available (mA): 500
              Current Required (mA): 500
              Extra Operating Current (mA): 0
```

2. 输入编辑 adb_usb.ini 文件，文件不存在就如果没有就`touch adb_usb.ini`一个新文件，文件路径是`/Users/{username}/.android`,之后将上一步获取的Vendor ID粘贴进去
3. 重启adb服务`adb kill-server`，`adb start-server`，然后再用adb devices命令查看，即可发现该设备已经可以被识别出来了。

```bash
$ adb devices
List of devices attached 
19254464082042	device
```


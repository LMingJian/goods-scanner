# goods-scanner

## 这是什么？

这是一个支持扫描商品条形码并登记价格的 Flutter 应用。

为什么要编写这个？主要是希望给没有专业收银设备的小卖部提供一个简单的计价工具，避免因商品过多而忘记价格。

## 设计思路

- 首先用户会通过应用，开启摄像头，然后对准条形码进行扫描。
- 接着程序搜索数据库，若条形码在之前被扫过并登记过价格，则展示对应的商品名称和价格；若数据库搜索没有结果，则用户可以对扫码结果进行登记，记录价格，以便在下一次扫描到同一条形码时展示。
- 为了数据的可移植，应用使用 SQLite 进行存储，对应的 db 文件存放在 `/0/Android/com.xxx.xxx/files` 中。

## 注意

- 项目支持的最低 Android SDK 为 21，请在运行代码前修改 `.\android\app\build.gradle` 里的 `minSdkVersion` 为 21。
- 项目使用 Flutter 3.10.0
- 项目使用 Dart 3.0.0

## 图示

<img src=".\picture\1.png" alt="1" style="zoom:50%;" />  <img src=".\picture\2.png" alt="2" style="zoom:50%;" />  <img src=".\picture\3.png" alt="3" style="zoom:50%;" />
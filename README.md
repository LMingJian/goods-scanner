# goods-scanner

@LMingJian 2025

## 这是什么？

这是一个支持扫描商品条形码并登记价格的 Flutter 应用。

为什么要编写这个？主要是希望给没有专业收银设备的小卖部提供一个简单的计价工具，避免因商品过多而忘记价格。

## 设计思路

- 首先用户会通过应用，开启摄像头，然后对准条形码进行扫描。
- 接着程序搜索数据库，若条形码在之前被扫过并登记过价格，则展示对应的商品名称和价格；若数据库搜索没有结果，则用户可以对扫码结果进行登记，记录价格，以便在下一次扫描到同一条形码时展示。
- 为了数据的可移植，应用使用 SQLite 进行存储，对应的 db 文件存放在 `/0/Android/com.xxx.xxx/files` 中。

## 注意

- 项目使用 ~~Flutter 3.16.5~~，2025-12-30 升级为 Flutter 3.38.5
- 项目使用 ~~Dart 3.2.3~~，2025-12-30 升级为 Dart 3.10.4
- APP 名称修改 `android/app/src/main/AndroidManifest.xml` 中的 `android:label`
- APP 包名修改，请使用正则搜索并替换 `com.(.*).goods`
- 运行 `lib\main.dart` 中的 `main()` 函数
- 依赖在 `pubspec.yaml`
- 打包 `flutter build apk --release`

## 图示

<img src=".\picture\1.png" alt="1" style="zoom:50%;" />  <img src=".\picture\2.png" alt="2" style="zoom:50%;" />  <img src=".\picture\3.png" alt="3" style="zoom:50%;" />

## 2025-12-30 更新事项

更新 Flutter 为当前最新版本 3.38.5。

网络优化请参照以下内容：

**添加环境变量**

```
PUB_HOSTED_URL="https://pub.flutter-io.cn" 
FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

**修改 Gradle 的下载地址**

Path：`android\gradle\wrapper\gradle-wrapper.properties`

```
distributionUrl=https\://mirrors.aliyun.com/macports/distfiles/gradle/gradle-8.14-all.zip
```

**配置 build.gradle.kts 和 settings.gradle.kts 文件**

Path：`android\build.gradle.kts, settings.gradle.kts`

```
repositories {
    maven(url = "https://maven.aliyun.com/repository/public/") 
    maven(url = "https://maven.aliyun.com/repository/central") 
    maven(url = "https://maven.aliyun.com/repository/google") 
    maven(url = "https://maven.aliyun.com/repository/gradle-plugin")
}
```

## 2024-01-30 更新事项

替换依赖 flutter_zxing 为 ^1.5.2。

由于这个版本的 flutter_zxing 最低要求 Dart 为 3.1.0，因此需要更新 Flutter 版本来适应。

注意，在替换版本后，项目构建会强制连接 Github，在中国的环境中，需要挂代理，或使用其他加速方式。

注意，如果用户使用 Steam++ 这类加速软件，则项目构建会出现报错：PKIX path building failed，这是由于 Java 无法识别经过加速后的 Github 连接是否安全，SSL 验证无法通过。解决方法是通过 Java 自带的 kettool 将加速软件的证书导入。

参考：[JAVA 导入信任证书 (Keytool 的使用)](https://blog.csdn.net/ljskr/article/details/84570573)

```bash
# 使用管理员权限开启命令行
# keytool 和 java 在同一个文件夹内
cd $JAVA_HOME/bin/
.\keytool -import -alias githubsteam -keystore ../lib/security/cacerts -file SteamTools.Certificate.cer
# SteamTools.Certificate.cer 是 Steam++ 的证书
# 导入成功后通过下面命令查看
.\keytool -list -keystore ../lib/security/cacerts
```

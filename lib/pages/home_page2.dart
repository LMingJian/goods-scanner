import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:goods_scanner/models/models.dart';
import 'package:goods_scanner/utils/sql.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:flutter/foundation.dart';

class GoodsScannerApp extends StatefulWidget {
  const GoodsScannerApp({super.key});

  @override
  State<GoodsScannerApp> createState() => _GoodsScannerApp();
}

class _GoodsScannerApp extends State<GoodsScannerApp> {
  late DatabaseHelper dbHelper;
  //late ScanHelper scanHelper;
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  bool isEditing = false;
  late Goods _goods;
  DateTime _lastPressedAt = DateTime(0);
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);
    //scanHelper = ScanHelper();
    dbHelper = DatabaseHelper();
    dbHelper.initDB().whenComplete(() async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('商品扫描器'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  /*
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            TextFormField(
                              controller: nameController,
                              decoration:
                                  const InputDecoration(labelText: '商品名'),
                            ),
                            TextFormField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              decoration:
                                  const InputDecoration(labelText: '价格'),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: ElevatedButton(
                                        onPressed: addOrEditGoods,
                                        child: const Text('提交'),
                                      )),
                                ])
                          ]))),*/
                  Expanded(flex: 1, child: SafeArea(child: goodsWidget())),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const ScanPage()));
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        debugPrint(_lastPressedAt.toString());
        if (_lastPressedAt == DateTime(0) ||
            DateTime.now().difference(_lastPressedAt) >
                const Duration(seconds: 1)) {
          _lastPressedAt = DateTime.now();
          _showToast();
          return; // 不退出
        }
        return; //退出
      },
    );
  }

  void _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: const Text("再按一次退出"),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Future<void> addOrEditGoods() async {
    String name = nameController.text;
    String price = priceController.text;

    if (!isEditing) {
      Goods goods = Goods(name: name, price: price);
      await addGoods(goods);
    } else {
      _goods.price = price;
      _goods.name = name;
      await updateGoods(_goods);
    }
    resetData();
    setState(() {});
  }

  Future<int> addGoods(Goods goods) async {
    return await dbHelper.insertGoods(goods);
  }

  Future<int> updateGoods(Goods goods) async {
    return await dbHelper.updateGoods(goods);
  }

  void resetData() {
    nameController.clear();
    priceController.clear();
    isEditing = false;
  }

  Widget goodsWidget() {
    return FutureBuilder(
      future: dbHelper.retrieveGoods(),
      builder: (BuildContext context, AsyncSnapshot<List<Goods>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, position) {
              return Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: const Icon(Icons.delete_forever),
                ),
                key: UniqueKey(),
                onDismissed: (DismissDirection direction) async {
                  await dbHelper.deleteGoods(snapshot.data![position].id!);
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => populateFields(snapshot.data![position]),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12.0,
                                  12.0,
                                  12.0,
                                  6.0,
                                ),
                                child: Text(
                                  snapshot.data![position].name,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  '${snapshot.data![position].price}元',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 2.0, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void populateFields(Goods goods) {
    _goods = goods;
    nameController.text = _goods.name;
    priceController.text = _goods.price;
    isEditing = true;
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPage();
}

class _ScanPage extends State<ScanPage> {
  Code? result;
  Codes? multiResult;

  bool isMultiScan = false;

  bool showDebugInfo = false;
  int successScans = 0;
  int failedScans = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: scanWidget());
  }

  Widget scanWidget() {
    final isCameraSupported =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    if (kIsWeb) {
      // 如果应用程序被编译为在web上运行，则该常量为true。
      return const UnsupportedPlatformWidget();
    } else if (!isCameraSupported) {
      return const Center(child: Text('摄像头不支持'));
    } else if (result != null && result?.isValid == true) {
      return ScanResultWidget(
        result: result,
        onScanAgain: () => setState(() => result = null),
      );
    } else {
      return Stack(
        children: [
          ReaderWidget(
            onScan: _onScanSuccess,
            onScanFailure: _onScanFailure,
            isMultiScan: isMultiScan,
            showGallery: false,
            showToggleCamera: false,
            scanDelay: Duration(milliseconds: isMultiScan ? 50 : 500),
            resolution: ResolutionPreset.veryHigh,
            lensDirection: CameraLensDirection.back,
          ),
          if (showDebugInfo)
            DebugInfoWidget(
              successScans: successScans,
              failedScans: failedScans,
              error: isMultiScan ? multiResult?.error : result?.error,
              duration: isMultiScan
                  ? multiResult?.duration ?? 0
                  : result?.duration ?? 0,
              onReset: _onReset,
            ),
        ],
      );
    }
  }

  void _onScanSuccess(Code? code) {
    setState(() {
      successScans++;
      result = code;
    });
  }

  void _onScanFailure(Code? code) {
    setState(() {
      failedScans++;
      result = code;
    });
    if (code?.error?.isNotEmpty == true) {
      _showMessage(context, 'Error: ${code?.error}');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onReset() {
    setState(() {
      successScans = 0;
      failedScans = 0;
    });
  }
}

class DebugInfoWidget extends StatelessWidget {
  const DebugInfoWidget({
    super.key,
    required this.successScans,
    required this.failedScans,
    this.error,
    this.duration = 0,
    this.onReset,
  });

  final int successScans;
  final int failedScans;
  final String? error;
  final int duration;

  final Function()? onReset;

  @override
  Widget build(BuildContext context) {
    TextStyle? style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.white);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Success: $successScans', style: style),
                        const SizedBox(width: 10),
                        Text('Failed: $failedScans', style: style),
                        const SizedBox(width: 10),
                        Text('Duration: $duration ms', style: style),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(onPressed: onReset, child: const Text('Reset')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScanResultWidget extends StatefulWidget {
  const ScanResultWidget({
    super.key,
    required this.result,
    required this.onScanAgain,
  });

  final Code? result;
  final Function()? onScanAgain;

  @override
  State<ScanResultWidget> createState() => _ScanResultWidget();
}

class _ScanResultWidget extends State<ScanResultWidget> {
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    //scanHelper = ScanHelper();
    dbHelper = DatabaseHelper();
    dbHelper.initDB().whenComplete(() async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final priceController = TextEditingController();
    final priceController2 = TextEditingController();
    dynamic rawCode = '';
    FocusNode focusNode = FocusNode();
    FocusNode focusNode2 = FocusNode();
    return FutureBuilder(
      future: dbHelper.retrieveGoodsPrice(widget.result?.text),
      builder: (BuildContext context, AsyncSnapshot<List<Goods>> snapshot) {
        rawCode = widget.result?.text ?? 'x';
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // 数据库有数据
          priceController.text = snapshot.data![0].price;
          priceController2.text = snapshot.data![0].name;
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '码型: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.result?.format?.name ?? '未知编码',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '原码: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          widget.result?.text ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '名称: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: priceController2,
                          textAlign: TextAlign.center,
                          focusNode: focusNode2,
                          onTapOutside: (e) => {focusNode2.unfocus()},
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(focusNode2);
                          },
                          decoration: const InputDecoration(
                            helperText: '商品名称-已登记',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '价格: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: priceController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          focusNode: focusNode,
                          onTapOutside: (e) => {focusNode.unfocus()},
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(focusNode);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          decoration: const InputDecoration(helperText: '单位：元'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => updateGoods(
                          Goods(
                            code: rawCode.toString(),
                            name: priceController2.text.toString(),
                            price: priceController.text.toString(),
                          ),
                          context,
                        ),
                        child: const Text('提交'),
                      ),
                      const SizedBox(width: 60),
                      ElevatedButton(
                        onPressed: widget.onScanAgain,
                        child: const Text('继续扫描'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          // 数据库无数据
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '码型: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.result?.format?.name ?? '未知编码',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '原码: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          widget.result?.text ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '名称: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: priceController2,
                          textAlign: TextAlign.center,
                          focusNode: focusNode2,
                          onTapOutside: (e) => {focusNode2.unfocus()},
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(focusNode2);
                          },
                          decoration: const InputDecoration(
                            helperText: '商品名称-未登记',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '价格: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          controller: priceController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          focusNode: focusNode,
                          onTapOutside: (e) => {focusNode.unfocus()},
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(focusNode);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          decoration: const InputDecoration(helperText: '单位：元'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => addGoods(
                          Goods(
                            code: rawCode.toString(),
                            name: priceController2.text.toString(),
                            price: priceController.text.toString(),
                          ),
                          context,
                        ),
                        child: const Text('提交'),
                      ),
                      const SizedBox(width: 60),
                      ElevatedButton(
                        onPressed: widget.onScanAgain,
                        child: const Text('继续扫描'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> addGoods(Goods goods, dynamic context) async {
    dynamic result = await dbHelper.insertGoods(goods);
    debugPrint(result.toString());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GoodsScannerApp()),
      (route) => false,
    );
  }

  Future<void> updateGoods(Goods goods, dynamic context) async {
    dynamic result = await dbHelper.updateGoodsWithCode(goods);
    debugPrint(result.toString());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GoodsScannerApp()),
      (route) => false,
    );
  }
}

class UnsupportedPlatformWidget extends StatelessWidget {
  const UnsupportedPlatformWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('此平台尚不支持', style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

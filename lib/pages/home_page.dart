import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animations/animations.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  bool _isAlphabetical = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  final _recentList = ListView(
    key: UniqueKey(),
    children: [
      for (int i = 0; i < 20; i++) _AlbumTile((i + 1).toString()),
    ],
  );

  final _alphabeticalList = ListView(
    key: UniqueKey(),
    children: [
      for (final letter in _alphabet) _AlbumTile(letter),
    ],
  );

  static const _alphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text("商品列表$_counter"),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: InkWell(
                    customBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    onTap: () {
                      if (!_isAlphabetical) {
                        _controller.reset();
                        _controller.animateTo(0.5);
                      } else {
                        _controller.animateTo(1);
                      }
                      setState(() {
                        _isAlphabetical = !_isAlphabetical;
                      });
                    },
                    child: Row(
                      children: [
                        Text(_isAlphabetical ? '按字母升序' : '最近查找'),
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0)
                              .animate(_controller.view),
                          child: const Icon(Icons.arrow_drop_down),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageTransitionSwitcher(
                reverse: _isAlphabetical,
                transitionBuilder: (child, animation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.vertical,
                    child: child,
                  );
                },
                child: _isAlphabetical ? _alphabeticalList : _recentList,
              ),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: _incrementCounter,
            child: const Icon(Icons.add),
          ),
        ));
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile(this._title);
  final String _title;

  @override
  Widget build(BuildContext context) {
    final randomNumberGenerator = Random();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            '商品名 $_title',
            style: const TextStyle(fontSize: 25.0),
          ),
          trailing: Text(
            '${(randomNumberGenerator.nextInt(50) + 10).toString()} ' '元',
            style: const TextStyle(fontSize: 25.0),
          ),
        ),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }
}

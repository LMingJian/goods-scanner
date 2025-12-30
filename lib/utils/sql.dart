import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goods_scanner/models/models.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();

  DatabaseHelper._();

  late Database db;
  bool isdbInitialized = false;

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Future<void> initDB() async {
    Directory? appDocumentsDirectory = await getExternalStorageDirectory();
    String path = appDocumentsDirectory!.path;
    debugPrint(path);
    db = await openDatabase(
      join(path, 'GoodsScanner.db'),
      onCreate: (database, version) async {
        await database.execute("""
            CREATE TABLE goods (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL,
              price TEXT NOT NULL,
              code TEXT
            )
          """);
      },
      version: 1,
    );
    isdbInitialized = true;
  }

  Future<int> insertGoods(Goods goods) async {
    int result = await db.insert('goods', goods.toMap());
    return result;
  }

  Future<int> updateGoods(Goods goods) async {
    int result = await db.update(
      'goods',
      goods.toMap(),
      where: "id = ?",
      whereArgs: [goods.id],
    );
    return result;
  }

  Future<int> updateGoodsWithCode(Goods goods) async {
    int result = await db.update(
      'goods',
      {'name': goods.name, 'price': goods.price},
      where: "code = ?",
      whereArgs: [goods.code],
    );
    return result;
  }

  Future<List<Goods>> retrieveGoodsPrice(String? goodsCode) async {
    final List<Map<String, Object?>> queryResult = await db.query(
      'goods',
      where: "code = ?",
      whereArgs: [goodsCode],
    );
    return queryResult.map((e) => Goods.fromMap(e)).toList();
  }

  Future<List<Goods>> retrieveGoods() async {
    if (!isdbInitialized) {
      await Future.delayed(const Duration(seconds: 600));
    }
    final List<Map<String, Object?>> queryResult = await db.query('goods');
    return queryResult.map((e) => Goods.fromMap(e)).toList();
  }

  Future<void> deleteGoods(int id) async {
    await db.delete('goods', where: "id = ?", whereArgs: [id]);
  }
}

class Goods {
  int? id;
  String? code;
  String name;
  String price;

  Goods({
    this.id,
    this.code,
    required this.name,
    required this.price,
  });

  Goods.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        code = res["code"],
        name = res["name"],
        price = res["price"];

  Map<String, Object?> toMap() {
    return {'id': id, 'code': code, 'name': name, 'price': price};
  }
}

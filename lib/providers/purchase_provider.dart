import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/order_provider.dart';

class PurchaseItem {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItem> products;
  PurchaseItem({
    required this.products,
    required this.id,
    required this.amount,
    required this.dateTime,
  });
}
// This File useless


// String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/purchase.json";
class PurchaseProvider with ChangeNotifier {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<PurchaseItem> _prushase = [];

  List<PurchaseItem> get prushase {
    return _prushase;
  }

  Future fetchAndSetPurchase() async {
    String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/purchase/$currentUserId.json";
    http.Response res = await http.get(Uri.parse(url));
    Map<String, dynamic>? extractData = jsonDecode(res.body) as Map<String, dynamic>?;
    if (extractData == null) return;

    List<PurchaseItem> loadingPurchase = [];
    extractData.forEach((key, value) {
      loadingPurchase.add(
        PurchaseItem(
          id: key,
          amount: value["amount"],
          dateTime: DateTime.parse(value["dateTime"]),
          products: (value["productPurch"] as List<dynamic>)
              .map(
                (element) => CartItem(
                  id: element["id"],
                  price: element["price"],
                  quantity: element["quantity"],
                  title: element["title"],
                ),
              )
              .toList(),
        ),
      );
    });
    _prushase = loadingPurchase;
    notifyListeners();
  }

  // Future getFromOrder({required String orderId}) async {
  //   String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/orders/$currentUserId/$orderId.json";
  //   http.Response res = await http.get(Uri.parse(url));
  //   Map<String, dynamic>? extractData = jsonDecode(res.body) as Map<String, dynamic>?;

  //   if (extractData == null) return;

  //   List<PurchaseItem> loadingOrder = [];
  //   extractData.forEach((key, value) {
  //     loadingOrder.add(
  //       PurchaseItem(
  //         id: key,
  //         amount: value["amount"],
  //         dateTime: DateTime.parse(
  //           value["dateTime"],
  //         ),
  //       ),
  //     );
  //   });
  //   _prushase = loadingOrder;
  //   notifyListeners();
  // }

  sendToDatabase({required OrderItem item}) async {
    String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/purchase/$currentUserId.json";
    DateTime date = DateTime.now();
    try {
      http.Response res = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "id": item.id,
          "amount": item.amount,
          "dateTime": date.toIso8601String(),
          "productPurch": item.products
              .map((element) => {
                    "id": element.id,
                    "title": element.title,
                    "quantity": element.quantity,
                    "price": element.price,
                  })
              .toList(),
        }),
      );
    } catch (error) {
      print(error);
    }
  }
}

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double amount;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.products,
    required this.amount,
    required this.dateTime,
  });
}

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return _orders;
  }

  Future fetchAndSetOrders() async {
    String _userId = FirebaseAuth.instance.currentUser!.uid;

    final String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/orders/$_userId.json";
    try {
      final res = await http.get(Uri.parse(url));
      final extractData = jsonDecode(res.body) as Map<String, dynamic>?;

      if (extractData == null) return;


      List<OrderItem> loadingOrders = [];

      extractData.forEach((orderId, orderData) {
        loadingOrders.add(OrderItem(
          id: orderId,
          amount: orderData["amount"],
          dateTime: DateTime.parse(orderData["dateTime"]),
          products: (orderData["products"] as List<dynamic>)
              .map(
                (element) => CartItem(
                  id: element["id"],
                  title: element["title"],
                  quantity: element["quantity"],
                  price: element["price"],
                ),
              )
              .toList(),
        ));
      });

      return (_orders = loadingOrders.reversed.toList());
      // notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future addOrder({required List<CartItem> cartProducts, required double total}) async {
    String _userId = FirebaseAuth.instance.currentUser!.uid;

    final String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/orders/$_userId.json";

    try {
      final _dateTime = DateTime.now();
      final res = await http.post(
        Uri.parse(url),
        body: json.encode({
          "amount": total,
          "dateTime": _dateTime.toIso8601String(),
          "products": cartProducts
              .map((element) => {
                    "id": element.id,
                    "title": element.title,
                    "quantity": element.quantity,
                    "price": element.price,
                  })
              .toList(),
        }),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(res.body)["name"],
          amount: total,
          dateTime: _dateTime,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {}

    notifyListeners();
  }
}

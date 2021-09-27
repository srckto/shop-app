import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return _items;
  }

  int get itemsCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;

    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void addItem(String prodId, double price, String title) {
    if (_items.containsKey(prodId)) {
      _items.update(
          prodId,
          (currentItem) => CartItem(
                id: currentItem.id,
                title: currentItem.title,
                quantity: currentItem.quantity + 1,
                price: currentItem.price,
              ));
    } else {
      _items.putIfAbsent(
        prodId,
        () => CartItem(
          id: DateTime.now().toIso8601String(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String prodId) {
    _items.removeWhere((key, value) => key == prodId);
    notifyListeners();
  }

  void removeSingleItem(String prodId) {
    if (!_items.containsKey(prodId)) {
      return;
    } else {
      if (_items[prodId]!.quantity > 1) {
        _items.update(
          prodId,
          (currentItem) => CartItem(
            id: currentItem.id,
            title: currentItem.title,
            quantity: currentItem.quantity - 1,
            price: currentItem.price,
          ),
        );
      } else {
        _items.remove(prodId);
      }
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

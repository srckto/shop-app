import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  void _setFav(bool value) {
    isFavorite = value;
    notifyListeners();
  }

  Future toggleFavStat(String userId) async {
    final oldFav = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = "https://shop-app-80a69-default-rtdb.firebaseio.com/userFavorite/$userId/$id.json";
    try {
      final res = await http.put(
        Uri.parse(url),
        body: json.encode(isFavorite),
      );
      if (res.statusCode >= 400) {
        _setFav(oldFav);
      }
    } catch (error) {
      _setFav(oldFav);
    }
  }
}

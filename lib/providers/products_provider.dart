import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product_provider.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];


  List<Product> get items {
    return _items;
  }

  List<Product> get favoriteItems {
    return _items.where((proud) => proud.isFavorite == true).toList();
  }

  Product findItem(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future fetchAndSetProducts([bool filter = false]) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      String urlGetProducts = "https://shop-app-80a69-default-rtdb.firebaseio.com/products.json";
      final res = await http.get(Uri.parse(urlGetProducts));
      final extractData = jsonDecode(res.body) as Map<String, dynamic>?;

      String urlGetFavoriteProduct = "https://shop-app-80a69-default-rtdb.firebaseio.com/userFavorite/$userId.json";
      final resFav = await http.get(Uri.parse(urlGetFavoriteProduct));
      final extractFavData = jsonDecode(resFav.body);

      List<Product> loadingProd = [];

      if (extractData != null && !filter) {
        extractData.forEach((prodId, prodData) {
          loadingProd.add(Product(
            id: prodId,
            title: prodData["title"],
            description: prodData["description"],
            imageUrl: prodData["imageUrl"],
            price: prodData["price"],
            isFavorite: extractFavData == null ? false : extractFavData[prodId] ?? false,
          ));
        });
        _items = loadingProd;
        notifyListeners();
      }
      if (extractData != null && filter) {
        extractData.forEach((prodId, prodData) {
          if (prodData["creatorId"] == userId) {
            loadingProd.add(Product(
              id: prodId,
              title: prodData["title"],
              description: prodData["description"],
              imageUrl: prodData["imageUrl"],
              price: prodData["price"],
              isFavorite: extractFavData == null ? false : extractFavData[prodId] ?? false,
            ));
          }
        });
        _items = loadingProd;
        notifyListeners();
      }

      
    } catch (error) {
      print(" Error In fetchAndSetProducts : ${error.toString()}");
    }
  }

  Future addProduct({required Product newProduct}) async {
    final String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/products.json";
    var userId = FirebaseAuth.instance.currentUser!.uid;

    final res = await http.post(
      Uri.parse(url),
      body: json.encode({
        "creatorId": userId,
        "title": newProduct.title,
        "description": newProduct.description,
        "imageUrl": newProduct.imageUrl,
        "price": newProduct.price,
      }),
    );

    _items.add(Product(
      id: json.decode(res.body)["name"],
      title: newProduct.title,
      description: newProduct.description,
      imageUrl: newProduct.imageUrl,
      price: newProduct.price,
    ));
    notifyListeners();
  }

  Future updataProduct({required String id, required Product newProduct}) async {
    final String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/products/$id.json";
    final int indexProduct = _items.indexWhere((element) => element.id == id);

    try {
      await http.patch(Uri.parse(url),
          body: json.encode({
            // "creatorId": userId,
            "title": newProduct.title,
            "description": newProduct.description,
            "imageUrl": newProduct.imageUrl,
            "price": newProduct.price,
          }));
      _items[indexProduct] = newProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future deleteProduct({required String id}) async {
    final String url = "https://shop-app-80a69-default-rtdb.firebaseio.com/products/$id.json";

    final int indexProduct = _items.indexWhere((element) => element.id == id);
    Product? existProduct = _items[indexProduct];

    _items.removeAt(indexProduct);
    notifyListeners();

    final res = await http.delete(Uri.parse(url));

    if (res.statusCode >= 400) {
      _items.insert(indexProduct, existProduct);
      notifyListeners();
    }

    existProduct = null;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);
  static const route = "/ProductDetailsScreen";

  @override
  Widget build(BuildContext context) {
    final argId = ModalRoute.of(context)!.settings.arguments as String;
    final _productSelect = Provider.of<Products>(context, listen: false).findItem(argId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_productSelect.title),
      ),
      body: ListView(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: double.infinity,
              height: 400,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Image.network(
                _productSelect.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _productSelect.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Divider(thickness: 2),
                  Text(
                    _productSelect.description,
                    style: TextStyle(fontSize: 20),
                  ),
                  Divider(thickness: 2),
                  Text(
                    "\$${_productSelect.price}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
                  ),
                  SizedBox(height: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

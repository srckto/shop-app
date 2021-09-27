import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool _favoriteProducts;

  ProductsGrid(this._favoriteProducts);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final _products = _favoriteProducts ? productData.favoriteItems : productData.items;

    if (_products.isEmpty)
      return Center(
          child: Text(
        "Not Found Any Item",
        style: Theme.of(context).textTheme.headline3,
      ));

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 12,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: _products.length,
      itemBuilder: (BuildContext ctx, int index) => ChangeNotifierProvider.value(
        value: _products[index],
        child: ProductItem(),
      ),
    );
  }
}

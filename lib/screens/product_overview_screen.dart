import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/drawer_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/products_grid.dart';
import 'package:shop_app/widgets/shopping_icon.dart';
import 'package:shop_app/widgets/drawer.dart';

enum FilterOption { Favorite, AllProducts }

class ProductOverViewScreen extends StatefulWidget {
  ProductOverViewScreen({Key? key}) : super(key: key);

  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  bool _showOnlyFavorite = false;

  @override
  void initState() {
    super.initState();
    Provider.of<DrawerProvider>(context, listen: false).getDataToDrawer();
    Future.delayed(
      Duration(seconds: 4),
      () => Provider.of<DrawerProvider>(context, listen: false).getDataToDrawerFirstTime(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop App"),
        actions: [
          PopupMenuButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (FilterOption selectedOption) {
              if (selectedOption == FilterOption.Favorite) {
                setState(() {
                  _showOnlyFavorite = true;
                });
              } else {
                setState(() {
                  _showOnlyFavorite = false;
                });
              }
            },
            icon: Icon(Icons.more_vert_outlined),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Only favorite"),
                value: FilterOption.Favorite,
              ),
              PopupMenuItem(
                child: Text("Show all"),
                value: FilterOption.AllProducts,
              ),
            ],
          ),
          Consumer<CartProvider>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, CartScreen.route),
            ),
            builder: (BuildContext ctx, CartProvider value, Widget? child) {
              return ShoppingIcon(
                value: value.itemsCount.toString(),
                child: child!,
                color: Theme.of(context).canvasColor,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Products>(context, listen: false).fetchAndSetProducts(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          } else {
            return ProductsGrid(_showOnlyFavorite);
          }
        },
      ),
      drawer: DrawerWidget(),
    );
  }
}

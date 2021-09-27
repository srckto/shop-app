import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/drawer.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({Key? key}) : super(key: key);
  static const route = "/UserProductScreen";

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, EditProductScreen.route),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: Consumer<Products>(builder: (ctx, value, _) {
                return value.items.isEmpty
                    ? Center(
                        child: Text(
                          "You Don't Have Any Product",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      )
                    : ListView.builder(
                        itemCount: value.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(value.items[index].imageUrl),
                                    // child: Image.network(),
                                  ),
                                  SizedBox(width: 10),
                                  Text(value.items[index].title),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.pushNamed(context, EditProductScreen.route, arguments: value.items[index].id);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Theme.of(context).errorColor,
                                    onPressed: () async {
                                      try {
                                        await value.deleteProduct(id: value.items[index].id);
                                      } catch (error) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Delete Field"),
                                        ));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              }),
            );
          }
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/drawer_provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/screens/order_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';

// ignore: must_be_immutable
class DrawerWidget extends StatelessWidget {
  DrawerWidget({Key? key}) : super(key: key);

  String? _email;
  String? _imageURL;
  String? _userName;

  @override
  Widget build(BuildContext context) {
    _email = Provider.of<DrawerProvider>(context).email;
    _imageURL = Provider.of<DrawerProvider>(context).imageURL;
    _userName = Provider.of<DrawerProvider>(context).userName;
    List<OrderItem> _orders = Provider.of<OrderProvider>(context).orders;

    return Drawer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            _headerDrawer(context),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, -5),
                    )
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    ListTile(
                      title: Text("Shop", style: Theme.of(context).textTheme.headline4),
                      leading: Icon(Icons.shop_2_rounded, size: 25),
                      selectedTileColor: Theme.of(context).accentColor,
                      onTap: () => Navigator.pushReplacementNamed(context, "/"),
                    ),
                    Divider(thickness: 2, endIndent: 5.0, indent: 5.0),
                    ListTile(
                      title: Text("Orders", style: Theme.of(context).textTheme.headline4),
                      leading: Icon(Icons.payment, size: 25),
                      selectedTileColor: Theme.of(context).accentColor,
                      onTap: () => Navigator.pushReplacementNamed(context, OrderScreen.route),
                      trailing: (_orders.length > 0)
                          ? CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Text("${_orders.length}"),
                            )
                          : null,
                    ),
                    Divider(thickness: 2, endIndent: 5.0, indent: 5.0),
                    ListTile(
                      title: Text("Manage Products", style: Theme.of(context).textTheme.headline4),
                      leading: Icon(Icons.edit, size: 25),
                      selectedTileColor: Theme.of(context).accentColor,
                      onTap: () => Navigator.pushReplacementNamed(context, UserProductScreen.route),
                    ),
                    Divider(thickness: 2, endIndent: 5.0, indent: 5.0),
                    ListTile(
                        title: Text("LogOut", style: Theme.of(context).textTheme.headline4),
                        leading: Icon(Icons.logout, size: 25),
                        selectedTileColor: Theme.of(context).accentColor,
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Provider.of<DrawerProvider>(context, listen: false).clearData();
                        }),
                    Spacer(),
                    Container(
                      alignment: Alignment.bottomCenter,
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(2, -2),
                          )
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                          child: Text(
                        "V 0.0.0",
                        style: TextStyle(fontSize: 17),
                      )),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _headerDrawer(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 60, bottom: 40, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            foregroundImage: NetworkImage(_imageURL!),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName!,
                  style: Theme.of(context).textTheme.headline2,
                ),
                Text(
                  _email!,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

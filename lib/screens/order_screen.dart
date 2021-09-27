import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/order_provider.dart' show OrderProvider;
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/widgets/drawer.dart';
import 'package:shop_app/widgets/order_items.dart';

class OrderScreen extends StatelessWidget {
  static const route = "/OrderScreen";

  @override
  Widget build(BuildContext context) {
    List<OrderItem> _orders = Provider.of<OrderProvider>(context).orders;
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Screen"),
      ),
      drawer: DrawerWidget(),
      body: FutureBuilder(
        future: Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          } else
            return _orders.isEmpty
                ? Center(
                    child: Text(
                      "You Don't Have Any Order",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  )
                : ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OrderItemWidget(
                        order: _orders[index],
                      );
                    },
                  );
        },
      ),
    );
  }
}

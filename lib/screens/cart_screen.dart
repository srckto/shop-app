import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const route = "/CartScreen";

  @override
  Widget build(BuildContext context) {
    final _cart = Provider.of<CartProvider>(context);
    // final _productsProvider = Provider.of<Products>(context, listen: false);
    // final Product _product = Provider.of<Product>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  Text("Total : ", style: Theme.of(context).textTheme.headline5),
                  Spacer(),
                  Chip(
                    label: Text("\$ ${_cart.totalAmount.toStringAsFixed(2)}"),
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                  OrderButtom(cart: _cart),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _cart.itemsCount,
              itemBuilder: (BuildContext context, int index) {
                return CartItemWidget(
                  id: _cart.items.values.toList()[index].id,
                  price: _cart.items.values.toList()[index].price,
                  productId: _cart.items.keys.toList()[index],
                  quantity: _cart.items.values.toList()[index].quantity,
                  title: _cart.items.values.toList()[index].title,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButtom extends StatefulWidget {
  final CartProvider cart;
  OrderButtom({required this.cart});

  @override
  _OrderButtomState createState() => _OrderButtomState();
}

class _OrderButtomState extends State<OrderButtom> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _loading)
          ? null
          : () async {
              setState(() {
                _loading = true;
              });
              await Provider.of<OrderProvider>(context, listen: false).addOrder(cartProducts: widget.cart.items.values.toList(), total: widget.cart.totalAmount);
              setState(() {
                _loading = false;
              });
              widget.cart.clear();
            },
      child: _loading
          ? Center(
              child: Container(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          : Text("Order Now",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).buttonColor,
              )),
    );

    // return FutureBuilder(
    //   future:
    //   builder: (ctx, snapShot) {
    //     if (snapShot.connectionState == ConnectionState.waiting)
    //       return CircularProgressIndicator();
    //     else if (!snapShot.hasData)
    //       return Text("ORDER NOW");
    //     else {
    //       return TextButton(
    //         onPressed: () {},
    //         child: Text("ORDER NOW"),
    //       );
    //     }
    //   },
    // );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String productId;

  const CartItemWidget({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 25),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      confirmDismiss: (dismiss) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Are you sure?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text("No")),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Yes")),
              ],
            );
          },
        );
      },
      onDismissed: (dismiss) {
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      key: ValueKey(id),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: FittedBox(
                  child: Text(
                price.toString(),
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              )),
            ),
          ),
          title: Text(title, style: Theme.of(context).textTheme.headline2),
          subtitle: Text("Total : ${(price * quantity)}", textAlign: TextAlign.start),
          trailing: Text("x $quantity"),
        ),
      ),
    );
  }
}

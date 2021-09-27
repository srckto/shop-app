import 'package:flutter/material.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:intl/intl.dart' as date;

class OrderItemWidget extends StatelessWidget {
  final OrderItem order;
  const OrderItemWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ExpansionTile(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(
            "\$${order.amount}",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(date.DateFormat("dd/MM/yyyy hh:mm").format(order.dateTime)),
          children: order.products.map((element) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        element.title,
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        "\$${element.price}",
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

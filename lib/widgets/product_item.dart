import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';

import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/product_details_screen.dart';

// ignore: must_be_immutable
class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _cart = Provider.of<CartProvider>(context, listen: false);
    final Product _product = Provider.of<Product>(context, listen: false);

    final userID = FirebaseAuth.instance.currentUser!.uid;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, ProductDetailsScreen.route  , arguments: _product.id),
          child: Hero(
            tag: _product.id,
            child: FadeInImage(
              placeholder: AssetImage("assets/images/product-placeholder.png"),
              image: NetworkImage(_product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(_product.title, textAlign: TextAlign.center),
          trailing: IconButton(
            onPressed: () {
              _cart.addItem(_product.id, _product.price, _product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "added to cart",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: Theme.of(context).backgroundColor,
                action: SnackBarAction(label: "UNDO", onPressed: () => _cart.removeSingleItem(_product.id)),
              ));
            },
            icon: Icon(Icons.shopping_cart),
          ),
          leading: Consumer<Product>(
            builder: (ctx, value, _) => IconButton(
              icon: Icon(_product.isFavorite ? Icons.favorite : Icons.favorite_border_outlined),
              onPressed: () {
                _product.toggleFavStat(userID);
              },
            ),
          ),
        ),
      ),
    );
  }
}


// Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pushNamed(context, ProductDetailsScreen.route),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: FadeInImage(
//                 placeholder: AssetImage("assets/images/product-placeholder.png"),
//                 image: NetworkImage(selectedProduct.imageUrl),
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             child: Container(
//               height: 40,
//               color: Colors.red,
//               width: MediaQuery.of(context).size.width,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Consumer<Product>(
//                     child: IconButton(
//                       onPressed: () {},
//                       icon: Icon(
//                         Icons.favorite,
//                         color: Colors.black,
//                       ),
//                     ),
//                     builder: (ctx, value, child) {
//                       return child!;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );


//  ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: GridTile(
//         child: GestureDetector(
//           onTap: () => Navigator.pushNamed(context, ProductDetailsScreen.route),
//           child: Hero(
//             tag: selectedProduct.id,
//             child: FadeInImage(
//               placeholder: AssetImage("assets/images/product-placeholder.png"),
//               image: NetworkImage(selectedProduct.imageUrl),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         footer: GridTileBar(
//           backgroundColor: Theme.of(context).primaryColor,
//           title: Text(selectedProduct.title, textAlign: TextAlign.center),

//           trailing: IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.shopping_cart_outlined),
//           ),
//           leading: Consumer<Product>(
//             builder: (ctx, value, _) => IconButton(
//               icon: Icon(selectedProduct.isFavorite ? Icons.favorite : Icons.favorite_border_outlined),
//               onPressed: () {
//                 ctx.read<Product>().toggleFavStat(userID);
//               },
//             ),
//           ),
//           // leading: Consumer<Product>(
//           //   child: IconButton(
//           //     onPressed: () {},
//           //     icon: Icon(Icons.favorite),
//           //   ),
//           //   builder: (ctx, value, child) {
//           //     return child!;
//           //   },
//           // ),
//         ),
//       ),
//     );

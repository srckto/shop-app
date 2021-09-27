
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/drawer_provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/providers/purchase_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import 'package:shop_app/screens/order_screen.dart';
import 'package:shop_app/screens/product_details_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';

import 'providers/product_provider.dart';
import 'screens/auth_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DrawerProvider()),
        ChangeNotifierProvider.value(value: Products()),
        ChangeNotifierProvider.value(value: Product(description: "", id: "", imageUrl: "", price: 0.0, title: '')),
        ChangeNotifierProvider.value(value: CartProvider()),
        ChangeNotifierProvider.value(value: OrderProvider()),
        ChangeNotifierProvider.value(value: PurchaseProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  _selectHomePage() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();
        else {
          if (snapshot.hasData)
            return ProductOverViewScreen();
          else
            return AuthScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFB175FF),
        accentColor: Color(0xFFDCBCD0),
        canvasColor: Color(0xFFFFF2FF),
        backgroundColor: Colors.black87,
        splashColor: Color(0xFFDCBCD0),
        buttonColor: Color(0xFF1D190A),
        fontFamily: "IBM",
        textTheme: TextTheme(
          headline1: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 35,
            letterSpacing: 2,
          ),
          headline2: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          headline3: TextStyle(
            color: Color(0xFF1D190A),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
          headline4: TextStyle(
            color: Colors.black54,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          headline5: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // home: _selectHomePage(),
      routes: {
        "/": (_) => _selectHomePage(),
        CartScreen.route: (_) => CartScreen(),
        EditProductScreen.route: (_) => EditProductScreen(),
        OrderScreen.route: (_) => OrderScreen(),
        ProductDetailsScreen.route: (_) => ProductDetailsScreen(),
        UserProductScreen.route: (_) => UserProductScreen(),
      },
    );
  }
}

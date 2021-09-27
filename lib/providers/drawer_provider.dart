import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerProvider with ChangeNotifier {
  String? userName;
  String? imageURL;
  String? email;
  bool isInit = true;

  Future getDataToDrawerFirstTime() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).get();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    isInit = _pref.getBool("isInit") ?? true;
    if (isInit) {
      userName = userData["userName"];
      imageURL = userData["imageURL"];
      email = userData["email"];

      isInit = false;

      _pref.setString("userName", userName!);
      _pref.setString("imageURL", imageURL!);
      _pref.setString("email", email!);
      _pref.setBool("isInit", isInit);
    }
    notifyListeners();
  }

  Future getDataToDrawer() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    userName = _pref.getString("userName") ?? "";
    imageURL = _pref.getString("imageURL") ?? "";
    email = _pref.getString("email") ?? "";
    notifyListeners();
  }

  Future clearData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.remove("userName");
    _pref.remove("imageURL");
    _pref.remove("email");
    _pref.remove("isInit");
  }
}

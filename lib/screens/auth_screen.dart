import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = "/AuthScreen";

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

enum LogState { logIn, singUp }

class _AuthScreenState extends State<AuthScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();

  String _email = "";
  String _password = "";
  String _userName = "";

  File? _imageFile;

  TextEditingController _emailControllar = TextEditingController();
  TextEditingController _passwordControllar = TextEditingController();
  TextEditingController _userNameController = TextEditingController();

  LogState _logState = LogState.logIn;

  bool _visibilityPassword = true;
  bool _loadingState = false;

  late UserCredential _userCredential;

  Future _imagePicker(ImageSource src) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? getImage = await _picker.pickImage(source: src, imageQuality: 50, maxHeight: 150, maxWidth: 150);
    if (getImage != null) {
      setState(() {
        _imageFile = File(getImage.path);
      });
    } else {
      print("Not Selected Image");
    }
  }

  Future _submitData({String? email, String? password, File? image, String? userName, LogState? logState, BuildContext? ctx}) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      setState(() {
        _loadingState = true;
      });
      if (logState == LogState.logIn) {
        _userCredential = await _auth.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );
      } else {
        _userCredential = await _auth.createUserWithEmailAndPassword(
          email: email!,
          password: password!,
        );

        Reference ref = FirebaseStorage.instance.ref('images').child(_userCredential.user!.uid + ".jpg");
        await ref.putFile(image!);
        final imageURL = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(_userCredential.user!.uid).set({
          "email": email,
          "password": password,
          "userName": userName,
          "imageURL": imageURL,
        }) as CollectionReference?;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "";
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = "There is an error";
      }
      setState(() {
        _loadingState = false;
      });
      ScaffoldMessenger.of(ctx!).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: Theme.of(ctx).textTheme.headline2,
          ),
          backgroundColor: Theme.of(ctx).accentColor,
          behavior: SnackBarBehavior.floating,
          elevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _loadingState = false;
      });
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate())
      return;
    else {
      if (_imageFile == null && _logState == LogState.singUp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please insert an image",
              style: Theme.of(context).textTheme.headline2,
            ),
            backgroundColor: Theme.of(context).accentColor,
            behavior: SnackBarBehavior.floating,
            elevation: 7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
        return;
      } else {
        _formKey.currentState!.save();
        _submitData(
          email: _emailControllar.text,
          password: _passwordControllar.text,
          userName: _userNameController.text,
          image: _imageFile,
          logState: _logState,
          ctx: context,
        );
      }
    }
  }

  void _switchLogState() {
    if (_logState == LogState.logIn)
      setState(() {
        _logState = LogState.singUp;
      });
    else
      setState(() {
        _logState = LogState.logIn;
      });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _backgroundColorWidget(context),
          SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      child: Text(
                        _logState == LogState.logIn ? "LOG IN" : "SING UP",
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_logState == LogState.singUp) _userNameWidget(context),
                    const SizedBox(height: 25),
                    _emailWidget(context),
                    const SizedBox(height: 25),
                    _passwordWidget(context),
                    const SizedBox(height: 25),
                    if (_logState == LogState.singUp) _reEnterpasswordWidget(context),
                    if (_logState == LogState.singUp) const SizedBox(height: 25),
                    if (_logState == LogState.singUp) Text(" - AND ADD YOUR IMAGE - "),
                    if (_logState == LogState.singUp) SizedBox(height: 20),
                    if (_logState == LogState.singUp) _getImageWidget(),
                    const SizedBox(height: 30),
                    _logInOrSingUpButtonWidget(context),
                    SizedBox(height: 25),
                    Text(" - OR - "),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: _switchLogState,
                      child: Text(
                        _logState == LogState.logIn ? "Create a new account" : "Log In",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconButton _suffixIconPasswordWidget(bool val) {
    if (val)
      return IconButton(
        icon: Icon(Icons.visibility),
        onPressed: () {
          setState(() {
            _visibilityPassword = !_visibilityPassword;
          });
        },
      );
    else
      return IconButton(
        icon: Icon(Icons.visibility_off),
        onPressed: () {
          setState(() {
            _visibilityPassword = !_visibilityPassword;
          });
        },
      );
  }

  Container _backgroundColorWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).accentColor,
            Theme.of(context).canvasColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Container _logInOrSingUpButtonWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      child: _loadingState
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).buttonColor,
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).buttonColor,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _submit,
              child: _logState == LogState.logIn ? Text("LOG IN") : Text("SIGN UP"),
            ),
    );
  }

  Row _getImageWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => _imagePicker(ImageSource.gallery),
            child: Text("From Gallery"),
          ),
        ),
        Container(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => _imagePicker(ImageSource.camera),
            child: Text("From Camera"),
          ),
        ),
      ],
    );
  }

  Column _userNameWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, bottom: 3),
          child: Text(
            "UserName",
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
          child: TextFormField(
            controller: _userNameController,
            onChanged: (value) {
              setState(() {
                _userName = value;
              });
            },
            validator: (value) {
              if (_userName.trim().isEmpty) return "Please Enter a userName";
              return null;
            },
            onSaved: (value) {
              _userNameController.text = value!;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: "Enter your userName",
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ),
      ],
    );
  }

  Column _emailWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, bottom: 3),
          child: Text(
            "Email",
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
          child: TextFormField(
            controller: _emailControllar,
            onChanged: (value) {
              setState(() {
                _email = value;
              });
            },
            validator: (value) {
              if (_email.trim().isEmpty) return "Please Enter Email";
              if (!_email.contains("@")) return "Please Enter valid email";
              return null;
            },
            onSaved: (value) {
              _emailControllar.text = value!;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: "Enter your email",
              prefixIcon: Icon(Icons.email),
            ),
          ),
        ),
      ],
    );
  }

  Column _passwordWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, bottom: 3),
          child: Text(
            "Password",
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
          child: TextFormField(
            controller: _passwordControllar,
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
            validator: (value) {
              if (_password.trim().isEmpty) return "Please Enter Password";

              if (_password.length < 6) return "Password is too short";
              return null;
            },
            onSaved: (value) {
              _passwordControllar.text = value!;
            },
            obscureText: _visibilityPassword,
            decoration: InputDecoration(
              suffixIcon: _suffixIconPasswordWidget(_visibilityPassword),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              prefixIcon: Icon(Icons.lock),
              hintText: _logState == LogState.logIn ? "Enter your password" : "Enter a new password",
            ),
          ),
        ),
      ],
    );
  }

  Column _reEnterpasswordWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, bottom: 3),
          child: Text(
            "Enter a password again",
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
          child: TextFormField(
            validator: (value) {
              if (value != _password) return "Pssword doesn't match";
              return null;
            },
            obscureText: _visibilityPassword,
            decoration: InputDecoration(
              suffixIcon: _suffixIconPasswordWidget(_visibilityPassword),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              prefixIcon: Icon(Icons.lock),
              hintText: "Enter a new password again",
            ),
          ),
        ),
      ],
    );
  }
}

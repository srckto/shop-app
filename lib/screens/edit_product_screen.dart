import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);
  static const route = "/EditProductScreen";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _imageFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _key = GlobalKey<FormState>();
  TextEditingController _imageController = TextEditingController();

  Product _editProduct = Product(
    id: "",
    description: "",
    imageUrl: "",
    price: 0,
    title: "",
  );

  bool _isLoading = false;
  bool _isInit = true;

  Map<String, Object> _initialValue = {
    "id": "",
    "description": "",
    "imageUrl": "",
    "price": 0,
    "title": "",
  };

  void _updateImage() {
    if (!_imageFocusNode.hasFocus) {
      if ((_imageController.text.startsWith("http") || _imageController.text.startsWith("https")) &&
          (_imageController.text.endsWith(".png") || _imageController.text.endsWith(".jpg") || _imageController.text.endsWith(".jpeg"))) {
        return;
      } else {}
    }
  }

  Future<void> _saveForm() async {
    bool _isValid = _key.currentState!.validate();
    if (!_isValid) {
      return;
    } else {
      _key.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      if (_editProduct.id.isNotEmpty) {
        await Provider.of<Products>(context, listen: false).updataProduct(id: _editProduct.id, newProduct: _editProduct);
      } else {
        try {
          Provider.of<Products>(context, listen: false).addProduct(newProduct: _editProduct);
        } catch (error) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Text("There is an error from internet"),
            ),
          );
          print("error in file edit_product_screen in fuction _saveForm");
        }
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _imageFocusNode.addListener(_updateImage);
  }

  @override
  void dispose() {
    super.dispose();
    _imageFocusNode.removeListener(_updateImage);
    _priceFocusNode.dispose();
    _imageFocusNode.dispose();
    _descFocusNode.dispose();
    _imageController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      String? argProductId = ModalRoute.of(context)!.settings.arguments as String?;
      if (argProductId != null) {
        _editProduct = Provider.of<Products>(context, listen: false).findItem(argProductId);
        _initialValue = {
          "id": _editProduct.id,
          "description": _editProduct.description,
          "price": _editProduct.price,
          "title": _editProduct.title,
        };
        _imageController.text = _editProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Form(
              key: _key,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 7, bottom: 3),
                          child: Text(
                            "Title",
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
                            initialValue: _initialValue["title"].toString(),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_priceFocusNode);
                            },
                            validator: (value) {
                              if (value!.trim().isEmpty) return "Please Enter title";
                              return null;
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                id: _editProduct.id,
                                title: value!,
                                imageUrl: _editProduct.imageUrl,
                                price: _editProduct.price,
                                description: _editProduct.description,
                                isFavorite: _editProduct.isFavorite,
                              );
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Enter a new title",
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(left: 7, bottom: 3),
                          child: Text(
                            "Price",
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
                            initialValue: _initialValue["price"].toString(),
                            focusNode: _priceFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_descFocusNode);
                            },
                            validator: (value) {
                              if (value!.trim().isEmpty) return "Please Enter price";
                              if (double.tryParse(value) == null || double.parse(value) <= 0) return "Please Enter a valid value";
                              return null;
                            },
                            onSaved: (value) {
                              double _newPrice = double.parse(value!);
                              _editProduct = Product(
                                id: _editProduct.id,
                                title: _editProduct.title,
                                imageUrl: _editProduct.imageUrl,
                                price: _newPrice,
                                description: _editProduct.description,
                                isFavorite: _editProduct.isFavorite,
                              );
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Enter a new price",
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(left: 7, bottom: 3),
                          child: Text(
                            "Description",
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
                            initialValue: _initialValue["description"].toString(),
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            focusNode: _descFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_imageFocusNode);
                            },
                            validator: (value) {
                              if (value!.trim().isEmpty) return "Please Enter a description";
                              if (value.length < 6) return "description is too short";
                              return null;
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                id: _editProduct.id,
                                title: _editProduct.title,
                                imageUrl: _editProduct.imageUrl,
                                price: _editProduct.price,
                                description: value!,
                                isFavorite: _editProduct.isFavorite,
                              );
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Enter a new description",
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(left: 7, bottom: 3),
                          child: Text(
                            "Image",
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
                            controller: _imageController,
                            focusNode: _imageFocusNode,
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value!.trim().isEmpty) return "Please Enter an image";
                              if (!value.startsWith("http") || !value.startsWith("https")) {
                                return "Please enter a valid image";
                              }
                              // else if (Uri.tryParse(value) != null) {
                              //   return "Please enter a valid url";
                              // }
                              // if (!value.endsWith("png") || !value.endsWith("jpg") || !value.endsWith("jpeg")) {
                              //   return "X-Please enter a valid image";
                              // }
                              else
                                return null;
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                id: _editProduct.id,
                                title: _editProduct.title,
                                imageUrl: value!,
                                price: _editProduct.price,
                                description: _editProduct.description,
                                isFavorite: _editProduct.isFavorite,
                              );
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Enter a new image",
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor,
                              padding: EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              _saveForm();
                            },
                            child: Text(
                              "save",
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

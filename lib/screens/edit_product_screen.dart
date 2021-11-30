import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocus = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocus.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments != null
          ? ModalRoute.of(context)!.settings.arguments as String
          : null;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocus.removeListener(_updateImageUrl);
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlController.dispose();
    _imageUrlFocus.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocus.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() => _isLoading = true);
    if (_editedProduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .editProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (onError) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An error has occurred'),
                  content: Text(onError.toString()),
                  actions: [
                    TextButton(
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () => Navigator.of(ctx).pop()),
                  ],
                ));
      }
    }
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                        focusColor: Colors.black,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (title) =>
                          title!.isEmpty ? 'Please provide a title.' : null,
                      onFieldSubmitted: (value) =>
                          FocusScope.of(context).requestFocus(_priceFocus),
                      onSaved: (title) => _editedProduct = Product(
                        id: _editedProduct.id,
                        title: title!,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(_descriptionFocus),
                      focusNode: _priceFocus,
                      validator: (price) {
                        if (double.tryParse(price!) == null) {
                          return 'Please enter a price.';
                        }
                        if (double.parse(price) <= 0) {
                          return 'Enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (price) => _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: _editedProduct.description,
                        price: double.parse(price!),
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocus,
                      maxLines: 3,
                      validator: (description) {
                        if (description!.isEmpty) {
                          return 'Por favor informe uma descrição.';
                        }
                        if (description.length <= 9) {
                          return 'The description must contain more than 10 characters.';
                        }
                        return null;
                      },
                      onSaved: (description) => _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: description!,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Center(child: Text('Enter a URL'))
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.fitWidth,
                                ),
                        ),
                        Expanded(
                            child: TextFormField(
                          decoration: InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocus,
                          onEditingComplete: () {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) => _saveForm(),
                          validator: (imageUrl) {
                            if (imageUrl!.isEmpty) {
                              return 'Please enter a URL.';
                            }
                            if (!imageUrl.startsWith('http') &&
                                !imageUrl.startsWith('https')) {
                              return 'Please enter a valid URL.';
                            }
                            if (!imageUrl.endsWith('.png') &&
                                !imageUrl.endsWith('.jpg') &&
                                !imageUrl.endsWith('.jpeg')) {
                              return 'Enter a URL for an image.';
                            }
                            return null;
                          },
                          onSaved: (imageUrl) => _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: imageUrl!,
                            isFavorite: _editedProduct.isFavorite,
                          ),
                        )),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

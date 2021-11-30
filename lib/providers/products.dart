import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/htttp_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  final String? authToken;
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> _items = [];
  //bool _showFavoritesOnly = false;

  List<Product> get items {
    // if(_showFavoritesOnly) {
    //   return items.where((item) => item.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  //O que não fazer

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }
  //
  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser
        ? {
            'auth': authToken,
            'orderBy': json.encode("creatorId"),
            'equalTo': json.encode(userId),
          }
        : {
            'auth': authToken,
          };
    final urlProd = Uri.https(
        'flutter-update-47b1f-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products.json',
        filterString);
    final urlFav = Uri.https(
        'flutter-update-47b1f-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/$userId.json',
        {'auth': '$authToken'});
    try {
      final dataProduct = await http.get(urlProd);
      final decodedData = json.decode(dataProduct.body) as Map<String, dynamic>;
      final favoriteResponse = await http.get(urlFav);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      decodedData.forEach((keyProdId, valProdData) {
        loadedProducts.add(Product(
          id: keyProdId,
          title: valProdData['title'],
          description: valProdData['description'],
          price: valProdData['price'],
          imageUrl: valProdData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[keyProdId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw (e);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'flutter-update-47b1f-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products.json',
        {'auth': '$authToken'});
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (onError) {
      print(onError);
      throw onError;
    }
  }

  // Future<void> addProduct(Product product) {
  //   final url = Uri.https('flutter-update-47b1f-default-rtdb.asia-southeast1.firebasedatabase.app', '/products.json');
  //   return http.post(url, body: json.encode({
  //     'title': product.title,
  //     'description': product.description,
  //     'price': product.price,
  //     'imageUrl': product.imageUrl,
  //     'isFavorite': product.isFavorite,
  //   })).then((response) {
  //     final newProduct = Product(
  //         id: json.decode(response.body)['name'],
  //         title: product.title,
  //         description: product.description,
  //         price: product.price,
  //         imageUrl: product.imageUrl
  //     );
  //     _items.add(newProduct);
  //     notifyListeners();
  //   }).catchError((onError) {
  //     throw onError;
  //   });
  // }

  Future<void> editProduct(String id, Product editedProduct) async {
    final indexProd = _items.indexWhere((prod) => prod.id == id);
    if (indexProd >= 0) {
      final url = Uri.https(
          'flutter-update-47b1f-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/products/$id.json',
          {'auth': '$authToken'});
      await http.patch(url,
          body: json.encode({
            'title': editedProduct.title,
            'description': editedProduct.description,
            'price': editedProduct.price,
            'imageUrl': editedProduct.imageUrl,
          }));
      _items[indexProd] = editedProduct;
      notifyListeners();
    } else {
      print('fail');
    }
  }

  void deleteProduct(String id) {
    final url = Uri.https(
        'flutter-update-47b1f-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products/$id.json',
        {'auth': '$authToken'});
    final oldIndex = _items.indexWhere((prod) => prod.id == id);
    final oldProd = _items[oldIndex];
    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        _items.insert(oldIndex, oldProd);
        notifyListeners();
        throw HttpException('Could not delete product.');
      }
    });
    _items.removeAt(oldIndex);
    notifyListeners();
  }
}

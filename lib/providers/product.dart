import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String? token, String? userId) {
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.https(
        'flutter-update-47b1f-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/$userId/$id.json',
        {'auth': '$token'});
    final request = isFavorite
        ? http.put(
            url,
            body: json.encode({
              'title': title,
              'description': description,
              'price': price,
              'imageUrl': imageUrl,
              'isFavorite': isFavorite,
            }),
          )
        : http.delete(url);
    request.then((_) {
      print('Favorite status changed');
    }).catchError((error) {
      print(error);
      isFavorite = !isFavorite;
      notifyListeners();
    });
  }
}

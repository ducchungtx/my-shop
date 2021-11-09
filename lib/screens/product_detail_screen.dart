import 'package:flutter/material.dart';

class ProductDetailSreen extends StatelessWidget {
  // final String title;
  // final double price;

  // ProductDetailSreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('title'),
      ),
    );
  }
}

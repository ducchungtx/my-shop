import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/products_grid.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                  // Navigator.pushNamed(context, '/favorites');
                }
                if (selectedValue == FilterOptions.All) {
                  _showOnlyFavorites = false;
                  // Navigator.pushNamed(context, '/');
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => const [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          )
        ],
      ),
      body: ProductsGrid(_showOnlyFavorites),
    );
  }
}

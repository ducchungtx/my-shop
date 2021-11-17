import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Form(
          child: ListView(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(labelText: 'Title'),
            textInputAction: TextInputAction.next,
            maxLines: 1,
          ),
        ],
      )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shopping_list/models/category.dart';

class GroceryItemW extends StatelessWidget {
  const GroceryItemW({
    super.key,
    required this.title,
    required this.quantity,
    required this.category,
  });

  final String title;
  final int quantity;
  final Category category;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Container(width: 24, height: 24, color: category.color),
      trailing: Text('$quantity'),
    );
  }
}

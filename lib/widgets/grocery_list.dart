import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;
  void _loadItems() async {
    final url = Uri.https(
      'flutter-prep-e97e0-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data. please trey again later";
        });
      }
      // backend specific response for empty body 'null'
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedList = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere((cat) => cat.value.title == item.value['category'])
            .value;
        loadedList.add(
          GroceryItem(
            id: item.key,
            title: item.value['title'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedList;
        _isLoading = false;
      });
    } catch (error) {
       setState(() {
          _error = "Something went wrong. please trey again later";
        });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    // optimistic update
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
      'flutter-prep-e97e0-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // inserting the item again if it fails to delete
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : _isLoading
          ? Center(child: CircularProgressIndicator())
          : _groceryItems.isEmpty
          ? Center(child: Text('No items yet, try adding some!'))
          : ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (context, index) => Dismissible(
                key: ValueKey(_groceryItems[index].id),
                background: Container(
                  width: double.infinity,
                  color: Colors.red[400],
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete),
                ),
                onDismissed: (direction) => _removeItem(_groceryItems[index]),
                child: GroceryItemW(
                  title: _groceryItems[index].title,
                  quantity: _groceryItems[index].quantity,
                  category: _groceryItems[index].category,
                ),
              ),
            ),
    );
  }
}

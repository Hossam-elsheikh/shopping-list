import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  // global key gives access to the widget, and keeps it's internal state
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;
  void _saveItem() {
    final isValidated = _formKey.currentState!
        .validate(); // triggers onValidate in each input
    if (isValidated) {
      _formKey.currentState!.save(); // triggers onSave in each input
      Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          title: _enteredTitle,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new Item')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text('Title')),
                // you have to trigger this validator
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length >= 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null; // the value is valid
                },
                onSaved: (value) {
                  _enteredTitle = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(label: Text('Quantity')),
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null || // if not a number
                            int.tryParse(value)! <= 0) {
                          return 'Must be between a valid positive number';
                        }
                        return null; // the value is valid
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      onSaved: (value) {
                        _selectedCategory = value!;
                      },
                      initialValue: _selectedCategory,
                      items: [
                        for (final cat in categories.entries)
                          DropdownMenuItem(
                            value: cat.value,
                            child: Row(
                              spacing: 8,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: cat.value.color,
                                ),
                                Text(cat.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: Text('Reset'),
                  ),
                  ElevatedButton(onPressed: _saveItem, child: Text('Add item')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

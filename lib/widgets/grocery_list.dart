import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

// import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  @override
  void
      initState() //* initState basically allow the program to do initialization work when the State was created the first time
  {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'shopping-list-thingy-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');

    final response = await http.get(
        url); //* no body parameter for .get method , get is getting data not sending them.

    // print(response.body);

    final Map<String, dynamic> listData = json.decode(response
        .body); //? Specifying the data type here because the type of the body from the result is known. UPDATE: nvm specifying into Map<String,Map<String,dynamic>> yields an error

    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      //* .firstWhere only yield 1 item , the first matching item
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value["category"])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category));
    }
    setState(() {
      _groceryItems = loadedItems;
    });
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    _loadItems();

    // if (newItem == null) //? no need now, not passing items via screens anymore (HTTP stuffs)
    //   return;
    //{
    //}
    // setState(() {
    //? no need now, not passing items via screens anymore (HTTP stuffs)
    //* use setState here obviously, need to  update the list UI
    //  _groceryItems.add(newItem);
    // });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("You have no items yet!"),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) => _removeItem(_groceryItems[index]),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              (_groceryItems[index].quantity).toString(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(
                onPressed: () {
                  //*could be a stateless widget if we pass Context to addItem
                  _addItem();
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}

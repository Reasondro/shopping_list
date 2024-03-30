import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  var _isLoading = true;
  String? _error;
  @override
  void
      initState() //* initState basically allow the program to do initialization work when the State was created the first time
  {
    super.initState();
    _loadItems();
  }

//! BASICALLY USE FutureBuilder if you only want to load data/show states or other logic to the data than future will be ideal
  //! , other than that (manipulating) not
  void _loadItems() async {
    final url = Uri.https(
        'shopping-list-thingy-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');

    // throw Exception("An error occured!");//* for error from the http method. no internet connection, invalid domain etc.
    //? Exception here is the error that being catched by the catch keyword
    try {
      //* use try for code that could often possibly goes wrong
      final response = await http.get(
          url); //? no body parameter for .get method , get is getting data not sending them.

      if (response.statusCode >=
          400) //? anything above or equal to 400 is an error
      {
        setState(() {
          _error = "Failed to fetch data. Please try again later.";
        });
      }

      if (response.body ==
          "null") //* depends on the backend, sometimes null, "null", 404 etc. for firebase it's "null"
      {
        setState(() {
          _isLoading = false;
        });
        return;
      }
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
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _error = "Something went wrong! Please try again later.";
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    // _loadItems(); //* for optimization, no need to get request via _loadItems. add the new item locally via newItem.
    //* Note: the newItem already saved in the database, what we display here is the "local" newItem

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

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'shopping-list-thingy-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${item.id}.json'); //* emphasis on the last slash "/"

    //* NO need for async await here, we don't expect any resopnse from the backend when deleting. (remove in background)

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      //? Optional: show error message
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("You have no items yet!"),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

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

    if (_error != null) {
      content = Center(child: Text(_error!));
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
        //! BASICALLY USE FutureBuilder if you only want to load data/show states or other logic to the data than future will be ideal
        //! , other than that (manipulating) not
        body: content);
  }
}

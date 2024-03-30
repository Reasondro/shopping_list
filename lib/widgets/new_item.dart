// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

//TODO use riverpod provider instead of manually pass items

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey =
      GlobalKey<FormState>(); //* almost always need a global key with form

  String _enteredName = "";
  int _enteredQuantity = 1;

  Category _selectedCategory =
      categories[Categories.vegetables]!; //* set a default value
  // Category? _selectedCategory; //? this could also work

  var _isSending = false;
  void _saveItem() async {
    bool validation = _formKey.currentState!.validate();
    //* validation here checks all the validator value. So all validator must be true
    if (validation) {
      _formKey.currentState!
          .save(); //* the save function itself. Save the state of all the form fields
      setState(() {
        _isSending = true;
      });

      //! REMEMBER TO SAVE FIRST, THEN POST

      final url = Uri.https(
          'shopping-list-thingy-default-rtdb.asia-southeast1.firebasedatabase.app', //! MAKE SURE NO BACKSLASHES (/) HERE, EVEN IF IT'S FROM THE FIREBASE
          'shopping-list.json'); //* shopping-list.json as the node in the databse
      final response = await http.post(url,
          headers: {'Content-type': 'application/json'},
          body: json.encode({
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title
          }));
      //? could use .then((value) => something) here. use await though dart will add .then method for me

      // print(response.body);
      // print(response.statusCode);
      final Map<String, dynamic> resData = jsonDecode(response.body);

      if (!context.mounted)
      //*to check if some of the context from the async await doodly doo still present or not.
      //*if false then some of them still present (i.e. dont execute pop)
      {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: resData["name"],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory));
      // Navigator.of(context).pop(GroceryItem( //? disabled for now, cus http stuffs
      //     id: DateTime.now()
      //         .toString(), //* technically datetime isnt the best, but works for now
      //     name: _enteredName,
      //     quantity: _enteredQuantity,
      //     category: _selectedCategory));
      // print(_enteredName);
      // print(_enteredQuantity);
      // print(_selectedCategory
      //     .title); //* or _selectedCategory!.title if using the Category? way
      // print(validation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //* instead of TextField(). This is basically a cracked version of TextField()
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                validator: (value) {
                  //* built in function to check stuffs, this the one that shows the error message
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 and 50 characters";
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  // if (value == null){ return ;}
                  setState(() {
                    _enteredName = value!;
                  });
                  // _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    //* TextFormField is unconstrained horizontally like row
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be a valid positive number!";
                        } else {
                          return null;
                        }
                      },
                      //* onSaved being a method from TextFormField, always wants a string. keep in mind
                      //? could also use onChanged
                      onSaved: (value) {
                        //* tryParse vs parse. tryParse will yield null if fails whilst parse will throw an error if fails to convert
                        setState(() {
                          _enteredQuantity = int.parse(value!);
                        });
                        // _enteredQuantity = int.parse(value!);
                      },
                      initialValue: _enteredQuantity.toString(),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        // * DropdownButtomFormField is unconstrained too (conflict with column ??)
                        items: [
                          for (final category in categories
                              .entries) //* entries convert a map into an iterable
                            DropdownMenuItem(
                              //* have onSaved, but we here we need to select manually, category.value for instance
                              //* D.M.I. doesn't support initial value parameter
                              //* only supports value parameter which must be updated and rendered every time the selection changes
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    //? for the color boxes besides the title
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            //* use setState here so the build method will be rebuild (value show on screen )
                            _selectedCategory = value!;
                          });
                        }),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator())
                        : const Text("Add Item"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

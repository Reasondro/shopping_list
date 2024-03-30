// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shopping_list/data/categories.dart';

// import 'package:shopping_list/models/grocery_item.dart';
// import 'package:shopping_list/widgets/new_item.dart';

// class GroceryList extends StatefulWidget {
//   const GroceryList({super.key});

//   @override
//   State<GroceryList> createState() => _GroceryListState();
// }

// class _GroceryListState extends State<GroceryList> {
//   List<GroceryItem> _groceryItems = [];

//   // var _isLoading = true;
//   late Future<List<GroceryItem>> _loadedItems;
//   //* we have no initial value, but we will have a value before it's being used the first time
//   String? _error;

//   @override
//   void
//       initState() //* initState basically allow the program to do initialization work when the State was created the first time
//   {
//     super.initState();
//     _loadedItems = _loadItems();
//   }

//   //! BASICALLY USE FutureBuilder if you only want to load data/show states or other logic to the data than future will be ideal
//   //! , other than that (manipulating) not
//   Future<List<GroceryItem>> _loadItems() async {
//     final url = Uri.https(
//         'shopping-list-thingy-default-rtdb.asia-southeast1.firebasedatabase.app',
//         'shopping-list.json');

//     // throw Exception("An error occured!");//* for error from the http method. no internet connection, invalid domain etc.
//     //? Exception here is the error that being catched by the catch keyword

//     //* use try for code that could often possibly goes wrong
//     final response = await http.get(
//         url); //? no body parameter for .get method , get is getting data not sending them.

//     if (response.statusCode >=
//         400) //? anything above or equal to 400 is an error
//     {
//       throw Exception("Failed to fetch grocery items. Please try again later.");
//     }

//     if (response.body ==
//         "null") //* depends on the backend, sometimes null, "null", 404 etc. for firebase it's "null"
//     {
//       return []; //? returns an empty list if we failed to get data
//     }
//     final Map<String, dynamic> listData = json.decode(response
//         .body); //? Specifying the data type here because the type of the body from the result is known. UPDATE: nvm specifying into Map<String,Map<String,dynamic>> yields an error

//     final List<GroceryItem> loadedItems = [];

//     for (final item in listData.entries) {
//       //* .firstWhere only yield 1 item , the first matching item
//       final category = categories.entries
//           .firstWhere(
//               (catItem) => catItem.value.title == item.value["category"])
//           .value;
//       loadedItems.add(GroceryItem(
//           id: item.key,
//           name: item.value["name"],
//           quantity: item.value["quantity"],
//           category: category));
//     }
//     return loadedItems;
//   }

//   void _addItem() async {
//     final newItem = await Navigator.of(context).push<GroceryItem>(
//       MaterialPageRoute(
//         builder: (ctx) => const NewItem(),
//       ),
//     );

//     if (newItem == null) {
//       return;
//     }
//     setState(() {
//       _groceryItems.add(newItem);
//     });
//     // _loadItems(); //* for optimization, no need to get request via _loadItems. add the new item locally via newItem.
//     //* Note: the newItem already saved in the database, what we display here is the "local" newItem
//   }

//   void _removeItem(GroceryItem item) async {
//     final index = _groceryItems.indexOf(item);
//     setState(() {
//       _groceryItems.remove(item);
//     });
//     final url = Uri.https(
//         'shopping-list-thingy-default-rtdb.asia-southeast1.firebasedatabase.app',
//         'shopping-list/${item.id}.json'); //* emphasis on the last slash "/"

//     //* NO need for async await here, we don't expect any resopnse from the backend when deleting. (remove in background)

//     final response = await http.delete(url);

//     if (response.statusCode >= 400) {
//       //? Optional: show error message
//       setState(() {
//         _groceryItems.insert(index, item);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Groceries"),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 //*could be a stateless widget if we pass Context to addItem
//                 _addItem();
//               },
//               icon: const Icon(Icons.add))
//         ],
//       ),
//       body: FutureBuilder(
//           //! BASICALLY USE FutureBuilder if you only want to load data/show states or other logic to the data than future will be ideal
//           //! , other than that (manipulating) not
//           future: _loadedItems,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Center(child: Text(snapshot.error.toString()));
//             }
//             if (snapshot.data!.isEmpty) {
//               return const Center(
//                 child: Text("You have no items yet!"),
//               );
//             }

//             return ListView.builder(
//               itemCount: snapshot.data!
//                   .length, //* changed _groceryItems to snapshot.data. WEIRD THIS FUTURE BUILDER IS HARD
//               itemBuilder: (ctx, index) => Dismissible(
//                 key: ValueKey(snapshot.data![index].id),
//                 onDismissed: (direction) => _removeItem(snapshot.data![index]),
//                 child: ListTile(
//                   title: Text(snapshot.data![index].name),
//                   leading: Container(
//                     width: 24,
//                     height: 24,
//                     color: snapshot.data![index].category.color,
//                   ),
//                   trailing: Text(
//                     (snapshot.data![index].quantity).toString(),
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];

  final _movieBox = Hive.box('movie_box');

  @override
  void initState() {
    super.initState();
    _refreshItems(); // Load data when app starts
  }

  // Get all items from the database
  void _refreshItems() {
    final data = _movieBox.keys.map((key) {
      final value = _movieBox.get(key);
      return {"key": key, "name": value["name"], "director": value['director'],"imgurl": value['imgurl']};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      // we use "reversed" to sort items in order from the latest to the oldest
    });
  }

  // Create new item
  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _movieBox.add(newItem);
    _refreshItems(); // update the UI
  }

  // Retrieve a single item from the database by using its key
  // Our app won't use this function but I put it here for your reference
  Map<String, dynamic> _readItem(int key) {
    final item = _movieBox.get(key);
    return item;
  }

  // Update a single item
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _movieBox.put(itemKey, item);
    _refreshItems(); // Update the UI
  }

  // Delete a single item
  Future<void> _deleteItem(int itemKey) async {
    await _movieBox.delete(itemKey);
    _refreshItems(); // update the UI

    // Display a snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An item has been deleted')));
  }

  // TextFields' controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(BuildContext ctx, int? itemKey) async {
    // itemKey == null -> create new item
    // itemKey != null -> update an existing item

    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _directorController.text = existingItem['director'];
      _imageController.text = existingItem['imgurl'];
    }

    showModalBottomSheet(
      backgroundColor: Color.fromARGB(255, 51, 50, 50),
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    
                    controller: _nameController,
                    decoration:  InputDecoration(hintText: 'Movie Name',hintStyle:GoogleFonts.lato(textStyle:TextStyle(color: Colors.white) ),
                    enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: Color.fromARGB(255, 190, 13, 13)),   
                      ),  
              focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 190, 13, 13)),
                   ), ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _directorController,
                   decoration:  InputDecoration(hintText: 'Director Name',hintStyle:GoogleFonts.lato(textStyle:TextStyle(color: Colors.white) ),
                    enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: Color.fromARGB(255, 190, 13, 13)),   
                      ),  
              focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 190, 13, 13)),
                   ),
                     ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _imageController,
                    keyboardType: TextInputType.url,
                    decoration:  InputDecoration(hintText: 'Poster Url',hintStyle:GoogleFonts.lato(textStyle:TextStyle(color: Colors.white) ),
                    enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: Color.fromARGB(255, 190, 13, 13)),   
                      ),  
              focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 190, 13, 13)),
                   ), ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () async {
                      // Save new item
                      if (itemKey == null) {
                        _createItem({
                          "name": _nameController.text,
                          "director": _directorController.text,
                          "imgurl":_imageController.text
                        });
                      }

                      // update an existing item
                      if (itemKey != null) {
                        _updateItem(itemKey, {
                          'name': _nameController.text.trim(),
                          'director': _directorController.text.trim(),
                          'imgurl': _imageController.text.trim()
                        });
                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _directorController.text = '';
                      _imageController.text='';

                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    child: Text(itemKey == null ? 'Create New' : 'Update',style: GoogleFonts.lato(textStyle: TextStyle(color:Color.fromARGB(255, 190, 13, 13))),),
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title:  Text('ToDo-Movie',style: GoogleFonts.lato(textStyle: TextStyle(color: Color.fromARGB(255, 190, 13, 13),fontSize: 25.0)),),
        backgroundColor: Colors.black,
      ),
      body: _items.isEmpty
          ? Center(
              child: Text(
                'No Data',
                style: GoogleFonts.lato(textStyle: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                )),
              ),
            )
          :AnimationLimiter(
        child: ListView.builder(
          padding: EdgeInsets.all(_w / 30),
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: _items.length,
          itemBuilder: (_, index) { 
            final currentItem = _items[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              delay: Duration(milliseconds: 100),
              child: SlideAnimation(
                duration: Duration(milliseconds: 2500),
                curve: Curves.fastLinearToSlowEaseIn,
                child: FadeInAnimation(
                  curve: Curves.fastLinearToSlowEaseIn,
                  duration: Duration(milliseconds: 2500),
                  child: Card(
                     margin: EdgeInsets.only(bottom: _w / 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                  color: Color.fromARGB(255, 169, 167, 167),
                  
                  elevation: 0,
                  child: InkWell(
                    onLongPress:() => _deleteItem(currentItem['key']),
                    onTap: () =>  _showForm(context, currentItem['key']),
                    child: Container(
                                  width: double.infinity,
                                  height: 250,
                                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(
                              currentItem['imgurl']),
                          fit: BoxFit.cover)),
                                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient:
                            LinearGradient(begin: Alignment.bottomRight, colors: [
                          Colors.black.withOpacity(.4),
                          Colors.black.withOpacity(.2),
                        ])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          currentItem['name'],
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            )
                          )
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          currentItem['director'],
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            )
                          )
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                                  ),
                                ),
                  ), 
                  
                 
                ),
                ),
              ),
            );
          },
        ),
      ),
          
          
          
          
          
      // Add new item button
      floatingActionButton: FloatingActionButton(
        backgroundColor:Color.fromARGB(255, 190, 13, 13),
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
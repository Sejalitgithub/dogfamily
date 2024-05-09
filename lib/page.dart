import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Family',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _dogImageUrl = '';
  List<String> _history = [];
  List<double> _prices = [];
  double _imageWidth = 400; // Set the desired width
  double _imageHeight = 400; // Set the desired height

  @override
  void initState() {
    super.initState();
    _fetchRandomDogImage();
    _loadHistory();
  }

  Future<void> _fetchRandomDogImage() async {
    final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _dogImageUrl = jsonData['message'];
        _history.add(_dogImageUrl);
        _prices.add(_generateRandomPrice()); // Add random price for the fetched image
        _saveHistory();
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  double _generateRandomPrice() {
    // Generate random price between 10 and 100
    return 10 + (90 * (DateTime.now().microsecondsSinceEpoch % 10000) / 10000);
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
      _prices = List<double>.from(prefs.getStringList('prices')!.map((price) => double.parse(price)));
    });
  }

  Future<void> _saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('history', _history);
    prefs.setStringList('prices', _prices.map((price) => price.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Family'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _dogImageUrl.isNotEmpty
                ? Container(
              width: _imageWidth,
              height: _imageHeight,
              child: Image.network(
                _dogImageUrl,
                fit: BoxFit.cover,
              ),
            )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchRandomDogImage,
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue, // Change this color to whatever you want
                // You can also customize other properties here if needed
              ),
              child: Text('Fetch New Image',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 15, // Text size
                  fontWeight: FontWeight.normal, // Text weight
                  // You can add more text style properties here as needed
                ),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(history: _history, prices: _prices, imageWidth: _imageWidth, imageHeight: _imageHeight),
                  ),

                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue, // Change this color to whatever you want
                // You can also customize other properties here if needed
              ),
              child: Text('View History',
              style:TextStyle(
                color:Colors.white,
                fontSize: 15, // Text size
                fontWeight: FontWeight.normal,
              )),
            ),
          ],
        ),
      ),
    );
  }
}


class HistoryPage extends StatefulWidget {
  final List<String> history;
  final List<double> prices;
  final double imageWidth;
  final double imageHeight;

  HistoryPage({
    required this.history,
    required this.prices,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> cartItems = []; // List to store selected items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.history.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    width: widget.imageWidth,
                    height: widget.imageHeight + 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          widget.history[index],
                          width: widget.imageWidth,
                          height: widget.imageHeight,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Price: \$${widget.prices[index].toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _addToCart(index); // Add to cart
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue, // Change this color to whatever you want
                            // You can also customize other properties here if needed
                          ),
                          child: Text('Add to Cart',
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 15, // Text size
                              fontWeight: FontWeight.normal, // Text weight
                              // You can add more text style properties here as needed
                            ),),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(cartItems: cartItems, prices: widget.prices),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue, // Change this color to whatever you want
                // You can also customize other properties here if needed
              ),
              child: Text('Go to Cart',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 15, // Text size
                  fontWeight: FontWeight.normal, // Text weight
                  // You can add more text style properties here as needed
                ),),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(int index) {
    setState(() {
      cartItems.add(widget.history[index]); // Add selected item to cartItems list
    });
  }
}



class CartPage extends StatefulWidget {
  final List<String> cartItems;
  final List<double> prices;

  CartPage({required this.cartItems, required this.prices});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double getTotalPrice() {
    double total = 0;
    for (int i = 0; i < widget.cartItems.length; i++) {
      total += widget.prices[i];
    }
    return total;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.cartItems[index],
                  width: 300, // Set the width to 300 pixels
                  height: 300, // Set the height to 300 pixels
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10), // Add spacing between image and price
                Text(
                  'Price: \$${widget.prices[index].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10), // Add spacing between price and button
                ElevatedButton(
                  onPressed: () {
                    _removeFromCart(index); // Remove from cart
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors
                        .lightBlue, // Change this color to whatever you want
                    // You can also customize other properties here if needed
                  ),
                  child: Text('Remove',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 15, // Text size
                      fontWeight: FontWeight.normal, // Text weight
                      // You can add more text style properties here as needed
                    ),),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          // Calculate and show total price
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Total Price'),
                content: Text(
                    'Total Price: \$${getTotalPrice().toStringAsFixed(2)}'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK',
                        style: TextStyle(
                            color: Colors.blue
                        )
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.attach_money,
            color: Colors.white),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      widget.cartItems.removeAt(
          index); // Remove selected item from cartItems list
      widget.prices.removeAt(index); // Remove corresponding price
    });
  }
}
// Module 10: Checkout & Order Placement
// -------------------------------------

import 'dart:async'; // (from Module 9)
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// CartItem model (unchanged from Module 9)
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  // Converts CartItem → Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Converts Map → CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }
}

// Provider with Firestore persistence and order placement
class CartProvider with ChangeNotifier {
  List<CartItem> _items = []; // local items
  String? _userId;
  StreamSubscription? _authSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> get items => _items;
  int get itemCount =>
      _items.fold(0, (previousValue, item) => previousValue + item.quantity);
  double get totalPrice =>
      _items.fold(0.0,
              (previousValue, item) => previousValue + (item.price * item.quantity));

  CartProvider() {
    if (kDebugMode) print('CartProvider initialized');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        if (kDebugMode) print('User logged out, clearing cart.');
        _userId = null;
        _items = [];
      } else {
        if (kDebugMode) print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }

  // Fetches Firestore cart
  Future<void> _fetchCart() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (kDebugMode) {
          print('Cart fetched successfully: ${_items.length} items');
        }
      } else {
        _items = [];
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching cart: $e');
      _items = [];
    }
    notifyListeners();
  }

  // Saves local cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return;
    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      if (kDebugMode) print('Cart saved to Firestore');
    } catch (e) {
      if (kDebugMode) print('Error saving cart: $e');
    }
  }

  // Add item
  void addItem(String id, String name, double price) {
    var index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(id: id, name: name, price: price));
    }
    _saveCart(); // Sync to Firestore
    notifyListeners();
  }

  // Remove item
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart(); // Sync to Firestore
    notifyListeners();
  }

  // 1. ADD THIS: Creates an order in the 'orders' collection
  Future<void> placeOrder() async {
    // 2. Check if we have a user and items
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }
    try {
      // 3. Convert our List<CartItem> to a List<Map> using toJson()
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      // 4. Get total price and item count
      final double total = totalPrice;
      final int count = itemCount;

      // 5. Create a new document in the 'orders' collection
      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData, // Our list of item maps
        'totalPrice': total,
        'itemCount': count,
        'status': 'Pending', // 6. IMPORTANT: For admin verification
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) print('Order placed successfully.');
      // 7. Note: We DO NOT clear the cart here.
    } catch (e) {
      if (kDebugMode) print('Error placing order: $e');
      rethrow; // 8. Re-throw so UI can handle
    }
  }

  // 9. ADD THIS: Clears the cart locally AND in Firestore
  Future<void> clearCart() async {
    // 10. Clear the local list
    _items = [];
    // 11. If logged in, clear the Firestore cart as well
    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        if (kDebugMode) print('Firestore cart cleared.');
      } catch (e) {
        if (kDebugMode) print('Error clearing Firestore cart: $e');
      }
    }
    // 13. Notify all listeners (this will clear the UI)
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

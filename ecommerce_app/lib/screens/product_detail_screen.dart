// Module 7: ProductDetailScreen
import 'package:flutter/material.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // 2. We will pass in the product's data (the map)
  final Map<String, dynamic> productData;
  // 3. We'll also pass the unique product ID (critical for 'Add to Cart' later)
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Extract data from the map for easier use
    final String name = productData['name'] ?? 'No name';
    final String description = productData['description'] ?? '';
    final String imageUrl = productData['imageUrl'] ?? '';
    final double price = (productData['price'] is num)
        ? (productData['price'] as num).toDouble()
        : 0.0;

    // Get CartProvider (Module 8)
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              imageUrl,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 300,
                  child:
                  Center(child: Icon(Icons.broken_image, size: 100)),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  Text('About this item',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Module 8 integration: add to cart
                      cart.addItem(productId, name, price);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart!'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      debugPrint('Product ID to add: $productId');
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

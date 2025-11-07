// Module 6: ProductCard widget (with tappable InkWell from Module 7)
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final double price;
  final String imageUrl;
  final VoidCallback onTap; // From Module 7

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.onTap, // required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the Card in an InkWell widget
    return InkWell(
      onTap: onTap, // 2. Call the function we passed in
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 2. This is for the Image
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                // 5. Show a loading spinner while the image downloads
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                // 6. Show an error icon if the URL is bad
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            // 7. A container for the text, with padding
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
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

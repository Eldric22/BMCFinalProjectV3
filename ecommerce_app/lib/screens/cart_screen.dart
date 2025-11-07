// Module 10: Checkout & Order Placement
// -------------------------------------
// This screen appears after a successful order placement

import 'package:flutter/material.dart';
import 'package:ecommerce_app/screens/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 100),
              const SizedBox(height: 30),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'Thank you for shopping with us.\nYou can track your orders in the Order History screen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

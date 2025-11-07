import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/admin_order_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': _imageUrlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });


      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added!')),
      );
      _formKey.currentState!.reset();
    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Manage All Orders'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminOrderScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Add New Product',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                    const InputDecoration(labelText: 'Product Name'),
                    validator: (v) => v!.isEmpty ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration:
                    const InputDecoration(labelText: 'Description'),
                    validator: (v) =>
                    v!.isEmpty ? 'Enter a description' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration:
                    const InputDecoration(labelText: 'Price'),
                    validator: (v) => v!.isEmpty ? 'Enter a price' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration:
                    const InputDecoration(labelText: 'Image URL'),
                    validator: (v) =>
                    v!.isEmpty ? 'Enter image URL' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _uploadProduct,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text('Upload Product'),
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

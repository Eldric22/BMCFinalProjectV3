// Part 1: Imports and Widget Definition
import 'package:ecommerce_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// 2. This is the State class
class _LoginScreenState extends State<LoginScreen> {
  // 3. Create a GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();
  // 4. Create TextEditingControllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Add a loading state variable
  bool _isLoading = false;
  // 3. Get an instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Part 2: The Login Function
  Future<void> _login() async {
    // 1. Check if the form is valid
    if (!_formKey.currentState!.validate()) {
      return; // If not valid, stop here
    }
    // 2. Set loading to true
    setState(() {
      _isLoading = true;
    });
    try {
      // 3. This is the Firebase command to sign in
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // 4. If login is successful, the AuthWrapper's stream
      //    will auto-navigate to HomeScreen. We don't need to do it here.
    } on FirebaseAuthException catch (e) {
      // 5. This 'catch' block handles Firebase-specific errors
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }

      // 6. Show the error message in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // 7. Catch any other general errors
      print(e);
    }
    // 8. ALWAYS set loading to false at the end
    if (mounted) { // Check if the widget is still on screen
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. A Scaffold provides the basic screen structure
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      // 2. SingleChildScrollView prevents the keyboard from causing an overflow
      body: SingleChildScrollView(
        child: Padding(
          // 3. Add padding around the form
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // 5. Assign our key to the Form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Navigate to Sign Up screen
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

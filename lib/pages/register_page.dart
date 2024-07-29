import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillahub/components/button.dart';
import 'package:fillahub/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  Future<void> _refresh() async {
    // Add your refresh logic here
    await Future.delayed(Duration(seconds: 1));
  }

  void signUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (passwordTextController.text != confirmPasswordTextController.text) {
      Navigator.pop(context);
      displayMessage("Passwords do not match");
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0],
        'bio': 'Empty bio..'
      });

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(getFriendlyErrorMessage(e.code));
    }
  }

  String getFriendlyErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email address is already in use. Please try another one.';
      case 'invalid-email':
        return 'The email address is not valid. Please enter a valid email.';
      case 'weak-password':
        return 'The password is too weak. Please enter a stronger password.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (builder) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Icon(
                      Icons.lock,
                      size: 100,
                    ),
                    const Text(
                      "Let's get Started",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 25),
                    MyTextField(
                        controller: emailTextController,
                        hintText: 'Email',
                        obscureText: false),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: passwordTextController,
                        hintText: 'Password',
                        obscureText: true),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: confirmPasswordTextController,
                        hintText: 'Confirm Password',
                        obscureText: true),
                    const SizedBox(height: 20),
                    MyButton(onTap: signUp, text: 'Sign Up'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login here",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

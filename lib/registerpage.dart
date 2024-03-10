import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venuebooking/bookingpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venuebooking/drawer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = false;

  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  void _clearErrors() {
    setState(() {
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
    });
  }

  Future<void> _signUp() async {
    _clearErrors();

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        if (emailController.text.isEmpty) _emailError = 'Email is required';
        if (passwordController.text.isEmpty)
          _passwordError = 'Password is required';
        if (confirmPasswordController.text.isEmpty)
          _confirmPasswordError = 'Confirm password is required';
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    try {
      setState(() {
        _loading = true;
      });

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Store user data in Firestore
        await _storeUserInFirestore(emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful for ${user.email}'),
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to BookingPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailError = 'Email is already in use';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during registration: ${e.message}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      print('Registration Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during registration'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _storeUserInFirestore(String email) async {
    // Set isAdmin to false by default
    bool isAdmin = false;

    // Check if the user should have admin access based on your criteria
    if (_checkIfUserIsAdmin(email)) {
      isAdmin = true;
    }

    // Encode the email to create a valid Firestore document ID
    String encodedEmail = Uri.encodeFull(email);

    await _firestore.collection('users').doc(encodedEmail).set({
      'email': email,
      'isAdmin': isAdmin,
    });
  }


  bool _checkIfUserIsAdmin(String email) {
    // Implement your logic to determine if the user should be an admin
    // For example, check if the email domain is admin@example.com
    return email.endsWith('@admin.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      drawer: MyDrawer(),
      body: DoubleBackToCloseApp(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Register",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                      color: Colors.deepPurple),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    hintText: 'E-mail',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    errorText: _emailError.isNotEmpty ? _emailError : null,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    hintText: 'Password',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    errorText: _passwordError.isNotEmpty ? _passwordError : null,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    hintText: 'Confirm password',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    errorText: _confirmPasswordError.isNotEmpty
                        ? _confirmPasswordError
                        : null,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: _loading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        snackBar: SnackBar(
          content: Text('Tap back again to leave'),
        ),
      ),
    );
  }
}

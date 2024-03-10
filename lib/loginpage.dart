import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:venuebooking/bookingpage.dart';
import 'package:venuebooking/drawer.dart';
import 'package:venuebooking/registerpage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _obscurePassword = true;
  bool _loading = false; // Loading state for email/password sign-in
  bool _googleLoading = false; // Loading state for Google sign-in
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleSignIn() async {
    try {
      if (!_isMounted) {
        return; // Check if the widget is still mounted
      }

      setState(() {
        _googleLoading = true; // Set loading state for Google sign-in
      });

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (!_isMounted) {
        return; // Check again after the asynchronous operation
      }

      if (googleSignInAccount == null) {
        // User canceled the sign-in
        _showSnackBar('Sign-in canceled');
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null && _isMounted) {
        // User signed in successfully
        _showSnackBar('Signed in as ${user.displayName}');

        // Navigate to BookingPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(),
          ),
        );
      } else {
        _showSnackBar('Sign-in failed');
      }
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled') {
        // User canceled the Google sign-in
        _showSnackBar('Google sign-in canceled');
      } else {
        print('Google Sign-In Error: $e');
        _showSnackBar('Error during sign-in');
      }
    } catch (error) {
      print('Google Sign-In Error: $error');
      _showSnackBar('Error during sign-in');
    } finally {
      if (_isMounted) {
        setState(() {
          _googleLoading = false; // Reset loading state for Google sign-in
        });
      }
    }
  }


  Future<void> _signInWithEmailAndPassword() async {
    try {
      if (!_isMounted) {
        return; // Check if the widget is still mounted
      }

      setState(() {
        _loading = true; // Set loading state for email/password sign-in
      });

      if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
        // Check if username or password is empty
        _showSnackBar('Username and password are required');
        return;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null && _isMounted) {
        // User signed in successfully
        _showSnackBar('Signed in as ${user.email}');

        // Navigate to BookingPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(),
          ),
        );
      } else {
        _showSnackBar('Sign-in failed');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showSnackBar('Wrong password provided for that user.');
      } else {
        _showSnackBar('Error during sign-in: ${e.message}');
      }
    } catch (error) {
      print('Email/Password Sign-In Error: $error');
      _showSnackBar('Error during sign-in');
    } finally {
      if (_isMounted) {
        setState(() {
          _loading = false; // Reset loading state for email/password sign-in
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                  "Log in",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                      color: Colors.deepPurple),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      hintText: 'username',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                ),
                SizedBox(
                  height: 12,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    hintText: 'password',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          )),
                      child: Text(
                        "Register Now",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _signInWithEmailAndPassword,
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.deepPurple),
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                                "Sign in",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Text("OR"),
                SizedBox(
                  height: 12,
                ),
                OutlinedButton(
                  onPressed: _handleSignIn,
                  child: Text('Sign In with Google'),
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

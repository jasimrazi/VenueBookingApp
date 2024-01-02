import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:venuebooking/bookingpage.dart';
import 'package:venuebooking/loginpage.dart';

class LoginStatus extends StatelessWidget {
  const LoginStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BookingPage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venuebooking/appbar.dart';
import 'package:venuebooking/homepage.dart';
import 'package:venuebooking/loginpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _reloadUser();
  }

  Future<User?> _reloadUser() async {
    User? user = await _auth.currentUser;
    if (user != null) {
      await user.reload();
      user = await _auth.currentUser; // Reload user data
    }
    return user;
  }

  String _extractUsername(String email) {
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<User?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading user data');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Column(
                      children: [
                        Text('User not signed in'),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                          child: Text('Go back to Login'),
                        ),
                      ],
                    );
                  } else {
                    User user = snapshot.data!;
                    String username =
                        _extractUsername(user.email ?? "default@default.com");

                    return Column(
                      children: [
                        Text(
                          '$username',
                          style: TextStyle(fontSize: 24),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _auth.signOut();

                            // Clear the user data in HomePage by popping the route
                            // and adding a local history entry to trigger initState
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          },
                          child: Text('Log Out'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

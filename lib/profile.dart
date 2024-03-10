import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venuebooking/drawer.dart';
import 'package:venuebooking/homepage.dart';
import 'package:venuebooking/loginpage.dart';
import 'package:venuebooking/allevents.dart'; // Import the AllEvents page

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
      appBar: AppBar(
        title: Text('Profile'),
      ),
      drawer: MyDrawer(),
      body: DoubleBackToCloseApp(
        child: SafeArea(
          child: Center(
            child: FutureBuilder<User?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading user data');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('User not signed in'),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person,
                            size: 60,
                            color: Colors.deepPurple), // Default profile icon
                      ),
                      SizedBox(height: 20),
                      Text(
                        '$username',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(), // Navigate to HomePage
                            ),
                          );
                        },
                        child: Text('Show your bookings'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
      
                          // Clear the user data in HomePage by popping the route
                          // and adding a local history entry to trigger initState
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllEvents(), // Navigate to AllEvents page
                            ),
                          );
                        },
                        child: Text('Log Out'),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllEvents(), // Navigate to AllEvents page
                            ),
                          );
                        },
                        child: Text('Back to HomePage'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
        snackBar: SnackBar(content: Text('Tap back again to leave'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:venuebooking/allevents.dart';
import 'package:venuebooking/homepage.dart';
import 'package:venuebooking/profile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 50,
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.deepPurple,
              size: 24,
            ),
            title: Text(
              'Home',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () => Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) => AllEvents())),
          ),
          ListTile(
            leading: Icon(
              Icons.bookmarks,
              color: Colors.deepPurple,
              size: 22,
            ),
            title: Text(
              'Bookings',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () => Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) => HomePage())),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.deepPurple,
              size: 24,
            ),
            title: Text(
              'Profile',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () => Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage())),
          ),
        ],
      ),
    );
  }
}
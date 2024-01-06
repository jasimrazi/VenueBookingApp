import 'package:flutter/material.dart';
import 'package:venuebooking/profile.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text('Venue Booking'),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            },
            icon: Icon(Icons.person))
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

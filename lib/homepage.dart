import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venuebooking/drawer.dart';
import 'package:venuebooking/events.dart';
import 'package:venuebooking/loginstatus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DocumentSnapshot> bookings = [];
  bool isLoading = false;
  bool isAdmin = false;

  Color _getStatusBorderColor(String? status) {
    Color borderColor;

    switch (status) {
      case 'pending':
        borderColor = Color(0xffffcc55); // Yellow
        break;
      case 'approved':
        borderColor = Color(0xff50C878); // Green
        break;
      case 'declined':
        borderColor = Color(0xffFF0505); // Red
        break;
      default:
        borderColor = Colors.grey;
    }

    return borderColor;
  }

  // Check if the user is admin
  Future<bool> _checkIfAdmin() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.email!;

      try {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();

        if (userSnapshot.exists) {
          bool userIsAdmin = userSnapshot['isAdmin'] ?? false;
          print('User is admin: $userIsAdmin');
          return userIsAdmin;
        } else {
          print('User document exists but isAdmin field is missing or null');
          return false;
        }
      } catch (e) {
        print('Error fetching user document: $e');
        return false;
      }
    } else {
      print('No user signed in.');
      return false;
    }
  }

  // Fetch bookings for the current user or all bookings if the user is an admin
  Future<void> _fetchBookings() async {
    setState(() {
      isLoading = true;
    });

    // Check if the user is an admin
    isAdmin = await _checkIfAdmin();

    print('isAdmin: $isAdmin');

    try {
      if (isAdmin) {
        // Fetch all bookings for admins
        QuerySnapshot querySnapshot = await _firestore
            .collection('Bookings')
            .orderBy('timestamp', descending: true)
            .get();

        setState(() {
          bookings = querySnapshot.docs;
          isLoading = false;
        });
      } else {
        // Fetch user-specific bookings
        User? user = _auth.currentUser;

        if (user != null) {
          String userId = user.uid;

          QuerySnapshot querySnapshot = await _firestore
              .collection('Bookings')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();

          setState(() {
            bookings = querySnapshot.docs;
            isLoading = false;
          });
        } else {
          print('No user signed in.');
          // Clear the bookings list when no user is signed in
          setState(() {
            bookings = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings'),
      ),
      drawer: MyDrawer(),
      body: DoubleBackToCloseApp(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchBookings,
            child: ListView.builder(
              physics:
                  AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              shrinkWrap: true,
              itemCount: bookings.isEmpty ? 1 : bookings.length + 1,
              itemBuilder: (context, index) {
                if (_auth.currentUser == null) {
                  // Display a message when no user is signed in
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'Please log in to see your bookings',
                          style: TextStyle(color: Color(0xffadadad)),
                        ),
                      ],
                    ),
                  );
                } else if (bookings.isEmpty) {
                  // Display a message when there are no bookings to show
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'No bookings to show',
                          style: TextStyle(color: Color(0xffadadad)),
                        ),
                      ],
                    ),
                  );
                } else if (index < bookings.length) {
                  // Display the booking item
                  var booking = bookings[index].data() as Map<String, dynamic>;
      
                  return Dismissible(
                    key: Key(bookings[index].id),
                    confirmDismiss: (DismissDirection direction) async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text(
                              "Are you sure you want to remove this booking?",
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text(
                                  "Remove",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                            ],
                          );
                        },
                      );
      
                      if (confirm) {
                        try {
                          await _firestore
                              .collection('Bookings')
                              .doc(bookings[index].id)
                              .delete();
      
                          // Remove the dismissed item from the list
                          setState(() {
                            bookings.removeAt(index);
                          });
                        } catch (e) {
                          print('Error deleting document: $e');
                        }
                      }
      
                      return confirm;
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.delete_sweep,
                        color: Colors.white,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (isAdmin) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllEvents(
                                eventId: bookings[index].id,
                                isAdmin: isAdmin,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking['eventName'] ?? '',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  booking['venue'] ?? '',
                                  style: TextStyle(color: Color(0xffadadad)),
                                ),
                              ],
                            ),
                            Container(
                              width: 100,
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _getStatusBorderColor(booking['state']),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                booking['state']?.toUpperCase() ?? 'UNKNOWN',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusBorderColor(booking['state']),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        snackBar: SnackBar(content: Text('Tap back again to leave'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginStatus(),
            ),
          );
          _fetchBookings();
        },
        label: Text(
          'Book',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        icon: Icon(
          Icons.add,
          size: 25,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

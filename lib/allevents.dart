import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venuebooking/appbar.dart';
import 'package:venuebooking/loginstatus.dart';
import 'package:venuebooking/alleventsdetails.dart'; // Import the AllEventsDetails page

class AllEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: ApprovedEventsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginStatus(),
            ),
          );
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
    );
  }
}

class ApprovedEventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bookings')
          .where('state', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> data =
                documents[index].data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllEventsDetails(
                      eventName: data['eventName'],
                      description: data['description'],
                      date: data['date'],
                      time: data['time'],
                      venue: data['venue'],
                    ),
                  ),
                );
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
                          data['eventName'] ?? '',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          data['venue'] ?? '',
                          style: TextStyle(
                            color: Color(0xffadadad),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      data['date'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venuebooking/drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class AllEventsDetails extends StatelessWidget {
  final String? eventId; // Declare eventId parameter
  final String? eventName;
  final String? description;
  final String? date;
  final String? time;
  final String? venue;
  final String? link;

  const AllEventsDetails({
    Key? key,
    this.eventId, // Receive eventId
    this.eventName,
    this.description,
    this.date,
    this.time,
    this.venue,
    this.link,
  }) : super(key: key);

  Future<String?> _getPosterUrl(String? eventId) async {
    try {
      if (eventId != null) {
        DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
            .collection('Bookings')
            .doc(eventId)
            .get();

        if (eventSnapshot.exists) {
          Map<String, dynamic> eventData =
              eventSnapshot.data() as Map<String, dynamic>;
          return eventData['poster'] as String?;
        } else {
          print('Document with event ID $eventId does not exist.');
        }
      }
      return null;
    } catch (e) {
      print('Error fetching poster URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '${eventName ?? ''}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 15),
              FutureBuilder<String?>(
                future: _getPosterUrl(eventId), // Pass eventId to _getPosterUrl
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading image');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return Image.network(snapshot.data!);
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: 15),
              Text(
                '${description ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
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
                    child: Text(
                      '${date ?? ''}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
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
                    child: Text(
                      '${venue ?? ''}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '${time ?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      final Uri _url = Uri.parse(link ?? '');
                      launchUrl(_url);
                    } on Exception catch (e) {
                      print(e);
                    } // Add logic to navigate to the register link
                  },
                  child: Text(
                    'Register Now',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

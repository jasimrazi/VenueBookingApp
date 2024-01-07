import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllEvents extends StatefulWidget {
  final String eventId;
  final bool isAdmin;

  const AllEvents({Key? key, required this.eventId, required this.isAdmin})
      : super(key: key);

  @override
  _AllEventsState createState() => _AllEventsState();
}

class _AllEventsState extends State<AllEvents> {
  late Map<String, dynamic> eventData;

  @override
  void initState() {
    super.initState();
    // Initialize eventData to an empty map
    eventData = {};
    // Fetch event details when the page is initialized
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    try {
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(widget.eventId)
          .get();

      setState(() {
        eventData = eventSnapshot.data() as Map<String, dynamic>;
      });

      // Print the whole eventData for debugging
      print('Event Data: $eventData');

      // Print the image URL to the console
      if (eventData['imageUrl'] != null) {
        print('Image URL: ${eventData['imageUrl']}');
      }
    } catch (e) {
      print('Error fetching event details: $e');
    }
  }


  Future<void> _updateEventState(String newState) async {
    try {
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(widget.eventId)
          .update({'state': newState});

      // Reload event details after updating state
      await _fetchEventDetails();

      // Navigate back to the homepage
      Navigator.pop(context);
    } catch (e) {
      print('Error updating event state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: eventData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Check if imageUrl is not null before displaying the image
                  if (eventData['imageUrl'] != null)
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        image: DecorationImage(
                          image: NetworkImage(
                            eventData['Image URL'] ?? '',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  SizedBox(height: 16),
                  Text(
                    'Event Name: ${eventData['eventName']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Venue: ${eventData['venue']}'),
                  SizedBox(height: 8),
                  Text('Date: ${eventData['date']}'),
                  SizedBox(height: 8),
                  Text('Time: ${eventData['time']}'),
                  SizedBox(height: 16),
                  if (widget.isAdmin)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Accept booking
                            _updateEventState('approved');
                          },
                          child: Text('Accept'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Decline booking
                            _updateEventState('declined');
                          },
                          child: Text('Decline'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';

class AllEventsDetails extends StatelessWidget {
  final String? eventName;
  final String? description;
  final String? date;
  final String? time;
  final String? venue;

  const AllEventsDetails({
    Key? key,
    this.eventName,
    this.description,
    this.date,
    this.time,
    this.venue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${eventName ?? ''}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description: ${description ?? ''}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${date ?? ''}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Time: ${time ?? ''}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Venue: ${venue ?? ''}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

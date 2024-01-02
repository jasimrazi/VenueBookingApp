import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:venuebooking/appbar.dart';

class BookingPage extends StatefulWidget {
  BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime time = DateTime.now();
  bool showDatePicker = false;
  bool showTimePicker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Event Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDatePicker = !showDatePicker;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        // height: 100.0,
                        color: Colors.deepPurple,
                        alignment: Alignment.center,
                        child: Text(
                          '${DateFormat('dd MMM yyyy').format(time)}',
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showTimePicker = !showTimePicker;
                        });
                      },
                      child: Container(
                        // height: 100.0,
                        padding: EdgeInsets.all(10),

                        color: Colors.deepPurple,
                        alignment: Alignment.center,
                        child: Text(
                          '${DateFormat('dd MMM yyyy').format(time)}',
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            //
            if (showDatePicker)
              SizedBox(
                height: 250,
                child: ScrollDateTimePicker(
                  itemExtent: 54,
                  infiniteScroll: true,
                  dateOption: DateTimePickerOption(
                    dateFormat: DateFormat('yyyyMMMdd'),
                    minDate: DateTime(2000, 6),
                    maxDate: DateTime(2024, 6),
                    initialDate: time,
                  ),
                  onChange: (datetime) => setState(() {
                    time = datetime;
                  }),
                ),
              ),
            if (showTimePicker)
              SizedBox(
                height: 250,
                child: ScrollDateTimePicker(
                  itemExtent: 54,
                  infiniteScroll: true,
                  dateOption: DateTimePickerOption(
                    dateFormat: DateFormat('hhmm'),
                    
                    minDate: DateTime(2000, 6),
                    maxDate: DateTime(2024, 6),
                    initialDate: time,
                  ),
                  onChange: (datetime) => setState(() {
                    time = datetime;
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

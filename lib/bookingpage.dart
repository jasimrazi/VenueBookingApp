import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:venuebooking/appbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BookingPage extends StatefulWidget {
  BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime time = DateTime.now();
  bool showDatePicker = false;
  bool showTimePicker = false;
  String selectedVenue = 'Audio Visual Theatre';
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showDatePicker = false;
          showTimePicker = false;
        });
      },
      child: Scaffold(
        appBar: MyAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Name',
                style: TextStyle(fontSize: 12, color: Colors.deepPurple),
              ),
              SizedBox(
                height: 8,
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 10.0,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style:
                              TextStyle(fontSize: 12, color: Colors.deepPurple),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showDatePicker = !showDatePicker;
                              showTimePicker = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black38),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${DateFormat('dd MMM yyyy').format(time)}',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style:
                              TextStyle(fontSize: 12, color: Colors.deepPurple),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showTimePicker = !showTimePicker;
                              showDatePicker = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black38),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${DateFormat('hh:mm a').format(time)}',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venue',
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: Alignment.center,
                    child: DropdownButton<String>(
                      value: selectedVenue,
                      dropdownColor: Colors.deepPurpleAccent,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedVenue = newValue!;
                        });
                      },
                      items: <String>[
                        'Audio Visual Theatre',
                        'Seminar Hall',
                        'Auditorium',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      icon: Icon(
                        Icons.unfold_more,
                        color: Colors.deepPurpleAccent,
                      ),
                      iconSize: 24,
                      underline: SizedBox(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Image Upload',
                style: TextStyle(fontSize: 12, color: Colors.deepPurple),
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: Alignment.center,
                  child: _image == null
                      ? Icon(
                          Icons.add_circle_outline,
                          size: 40,
                          color: Colors.deepPurpleAccent,
                        )
                      : Image.file(
                          _image!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
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
                      dateFormat: DateFormat('hh:mm a'),
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
      ),
    );
  }
}

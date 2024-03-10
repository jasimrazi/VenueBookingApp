import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:venuebooking/allevents.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venuebooking/drawer.dart';
import 'package:venuebooking/homepage.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay(hour: 16, minute: 0);
  bool showDatePicker = false;
  bool showTimePicker = false;
  bool showEndTimePicker = false;

  String selectedVenue = 'Audio Visual Theatre';
  File? _image;
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDescriptionController =
      TextEditingController(); // Added
  TextEditingController _registerLinkController =
      TextEditingController(); // Added
  bool _isSubmitting = false;
  bool _isEventNameEmpty = true;
  File? _posterImage; // Added

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _getPosterImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _posterImage = File(pickedFile.path);
      }
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _uploadImage(String userId) async {
    String fileName = 'booking_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageReference =
        FirebaseStorage.instance.ref().child('user_images/$userId/$fileName');
    UploadTask uploadTask = storageReference.putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> _uploadPoster(String userId) async {
    String fileName = 'poster_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageReference =
        FirebaseStorage.instance.ref().child('event_posters/$userId/$fileName');
    UploadTask uploadTask = storageReference.putFile(_posterImage!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<bool> hasDateAndTimeConflict() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Bookings')
          .where('state', isEqualTo: 'approved')
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        dynamic dateFromFirestore = document['date'];
        DateTime eventDate;
        if (dateFromFirestore is String) {
          eventDate = DateFormat('MMMM dd, yyyy').parse(dateFromFirestore);
        } else if (dateFromFirestore is Timestamp) {
          eventDate = dateFromFirestore.toDate();
        } else {
          print('Unexpected date format in Firestore');
          continue; // Skip this document
        }

        String existingVenue = document['venue'];
        if (existingVenue != selectedVenue) {
          continue; // Skip if venues are different
        }

        TimeOfDay existingStartTime = TimeOfDay(
          hour: document['startHour'],
          minute: document['startMinute'],
        );

        TimeOfDay existingEndTime = TimeOfDay(
          hour: document['endHour'],
          minute: document['endMinute'],
        );

        DateTime existingEventDateTimeStart = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          existingStartTime.hour,
          existingStartTime.minute,
        );

        DateTime existingEventDateTimeEnd = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          existingEndTime.hour,
          existingEndTime.minute,
        );

        DateTime selectedDateTimeStart = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        DateTime selectedDateTimeEnd = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          endTime.hour,
          endTime.minute,
        );

        if (selectedDateTimeEnd.isAfter(existingEventDateTimeStart) &&
            selectedDateTimeStart.isBefore(existingEventDateTimeEnd)) {
          return true; // Conflict found
        }
      }
      return false; // No conflict found
    } catch (e) {
      print('Error checking for conflicts: $e');
      return true; // Consider it as a conflict to prevent accidental bookings
    }
  }

  bool _validateAndSave() {
    bool isValid = true;

    if (_eventNameController.text.isEmpty) {
      setState(() {
        _isEventNameEmpty = false;
      });
      isValid = false;
    } else {
      setState(() {
        _isEventNameEmpty = true;
      });
    }

    return isValid;
  }

  Future<void> submitBooking() async {
    if (_validateAndSave()) {
      try {
        bool hasConflict = await hasDateAndTimeConflict();

        if (hasConflict) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conflict with existing event!'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          User? user = _auth.currentUser;

          if (user != null) {
            String userId = user.uid;
            String userName = user.displayName ?? 'Unknown User';

            String formattedDate =
                DateFormat('MMMM dd, yyyy').format(selectedDate);

            Timestamp timestamp = Timestamp.now();

            setState(() {
              _isSubmitting = true;
            });

            DateTime selectedDateTimeStart = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            DateTime selectedDateTimeEnd = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              endTime.hour,
              endTime.minute,
            );

            String formattedStartTime =
                DateFormat('hh:mm a').format(selectedDateTimeStart);
            String formattedEndTime =
                DateFormat('hh:mm a').format(selectedDateTimeEnd);

            await _firestore.collection('Bookings').add({
              'eventName': _eventNameController.text,
              'eventDescription': _eventDescriptionController.text,
              'date': formattedDate,
              'startHour': selectedTime.hour,
              'startMinute': selectedTime.minute,
              'endHour': endTime.hour,
              'endMinute': endTime.minute,
              'venue': selectedVenue,
              'time': '$formattedStartTime - $formattedEndTime',
              'imageURL': _image != null ? await _uploadImage(userId) : null,
              'registerlink': _registerLinkController.text,
              'poster':
                  _posterImage != null ? await _uploadPoster(userId) : null,
              'userId': userId,
              'userName': userName,
              'state': 'pending',
              'timestamp': timestamp
            });

            _eventNameController.clear();
            _eventDescriptionController.clear();
            _registerLinkController.clear();
            setState(() {
              _image = null;
              _posterImage = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Booking submitted successfully!')),
            );
          } else {
            print('No user signed in.');
          }
        }
      } catch (e) {
        print('Error submitting booking: $e');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _registerLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showDatePicker = false;
          showTimePicker = false;
          showEndTimePicker = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Booking Page'),
        ),
        drawer: MyDrawer(),
        body: DoubleBackToCloseApp(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Name',
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _eventNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      errorText: _isEventNameEmpty
                          ? null
                          : 'Please enter the event name',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Event Description',
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _eventDescriptionController,
                    maxLines: null,
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
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showDatePicker = !showDatePicker;
                                  showTimePicker = false;
                                  showEndTimePicker = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black38),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showTimePicker = !showTimePicker;
                                  showDatePicker = false;
                                  showEndTimePicker = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black38),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${selectedTime.format(context)}',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showEndTimePicker = !showEndTimePicker;
                                  showTimePicker = false;
                                  showDatePicker = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black38),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${endTime.format(context)}',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (showEndTimePicker)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showEndTimePicker = false;
                        });
                      },
                      child: SizedBox(
                        height: 180,
                        child: ScrollDateTimePicker(
                          itemExtent: 54,
                          infiniteScroll: true,
                          dateOption: DateTimePickerOption(
                            dateFormat: DateFormat('hh:mm a'),
                            minDate: DateTime(2000, 1, 1, 0, 0),
                            maxDate: DateTime(2000, 1, 1, 23, 59),
                            initialDate: DateTime(
                              2000,
                              1,
                              1,
                              endTime.hour,
                              endTime.minute,
                            ),
                          ),
                          onChange: (datetime) => setState(() {
                            endTime = TimeOfDay(
                              hour: datetime.hour,
                              minute: datetime.minute,
                            );
                          }),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  if (showDatePicker)
                    SizedBox(
                      height: 180,
                      child: ScrollDateTimePicker(
                        itemExtent: 54,
                        infiniteScroll: true,
                        dateOption: DateTimePickerOption(
                          dateFormat: DateFormat('MMM dd, yyyy'),
                          minDate: DateTime(2020, 1, 1),
                          maxDate: DateTime(2040, 12, 31),
                          initialDate: selectedDate,
                        ),
                        onChange: (datetime) => setState(() {
                          selectedDate = datetime;
                        }),
                      ),
                    ),
                  if (showTimePicker)
                    SizedBox(
                      height: 180,
                      child: ScrollDateTimePicker(
                        itemExtent: 54,
                        infiniteScroll: true,
                        dateOption: DateTimePickerOption(
                          dateFormat: DateFormat('hh:mm a'),
                          minDate: DateTime(2000, 1, 1, 0, 0),
                          maxDate: DateTime(2000, 1, 1, 23, 59),
                          initialDate: DateTime(
                            2000,
                            1,
                            1,
                            selectedTime.hour,
                            selectedTime.minute,
                          ),
                        ),
                        onChange: (datetime) => setState(() {
                          selectedTime = TimeOfDay(
                            hour: datetime.hour,
                            minute: datetime.minute,
                          );
                        }),
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venue',
                        style:
                            TextStyle(fontSize: 12, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: DropdownButton<String>(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(10.0),
                          value: selectedVenue,
                          dropdownColor: Colors.deepPurple.shade50,
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
                            color: Colors.deepPurple,
                          ),
                          iconSize: 24,
                          underline: SizedBox(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Link to Register',
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _registerLinkController,
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
                  SizedBox(height: 20),
                  Text(
                    'Permission Upload',
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 8),
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
                              color: Colors.deepPurple,
                            )
                          : Image.file(
                              _image!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Event Poster',
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: _getPosterImage,
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: _posterImage == null
                          ? Icon(
                              Icons.add_circle_outline,
                              size: 40,
                              color: Colors.deepPurple,
                            )
                          : Image.file(
                              _posterImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitBooking,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                      ),
                      child: _isSubmitting
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              backgroundColor: Colors.deepPurpleAccent,
                            )
                          : Text('Submit'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllEvents(),
                          ),
                        );
                      },
                      child: Text('Go Back to Homepage'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          snackBar: SnackBar(
            content: Text('Tap back again to leave'),
          ),
        ),
      ),
    );
  }
}

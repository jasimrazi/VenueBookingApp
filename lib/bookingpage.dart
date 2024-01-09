import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:venuebooking/appbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venuebooking/homepage.dart';

class BookingPage extends StatefulWidget {
  BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool showDatePicker = false;
  bool showTimePicker = false;
  String selectedVenue = 'Audio Visual Theatre';
  File? _image;
  TextEditingController _eventNameController = TextEditingController();
  bool _isSubmitting = false;
  bool _isEventNameEmpty = true; // Track if the event name is empty

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
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

  bool _validateAndSave() {
    bool isValid = true;

    // Validate and show error if the event name is empty
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
        User? user = _auth.currentUser;

        if (user != null) {
          String userId = user.uid;
          String userName = user.displayName ?? 'Unknown User';

          // Format the date as month, day, and year
          String formattedDate =
              DateFormat('MMMM dd, yyyy').format(selectedDate);

          // Get the current timestamp
          Timestamp timestamp = Timestamp.now();

          setState(() {
            _isSubmitting = true; // Set loading state
          });

          await _firestore.collection('Bookings').add({
            'eventName': _eventNameController.text,
            'date': formattedDate,
            'time': selectedTime.format(context),
            'venue': selectedVenue,
            'imageURL': _image != null ? await _uploadImage(userId) : null,
            'userId': userId,
            'userName': userName,
            'state': 'pending',
            'timestamp': timestamp
          });

          _eventNameController.clear();
          setState(() {
            _image = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking submitted successfully!')),
          );
        } else {
          print('No user signed in.');
        }
      } catch (e) {
        print('Error submitting booking: $e');
      } finally {
        setState(() {
          _isSubmitting = false; // Reset the loading state
        });
      }
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
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
        body: SingleChildScrollView(
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
                SizedBox(
                  height: 8,
                ),
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
                    // Show error message inside the event name TextField
                    errorText: _isEventNameEmpty
                        ? null
                        : 'Please enter the event name',
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
                            style: TextStyle(
                                fontSize: 12, color: Colors.deepPurple),
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
                                '${DateFormat('MMMM dd, yyyy').format(selectedDate)}',
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
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                                fontSize: 12, color: Colors.deepPurple),
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
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                if (showDatePicker)
                  SizedBox(
                    height: 180,
                    child: ScrollDateTimePicker(
                      itemExtent: 54,
                      infiniteScroll: true,
                      dateOption: DateTimePickerOption(
                        dateFormat: DateFormat(
                          'MMMM dd, yyyy',
                        ),
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
                        dropdownColor: Colors.deepPurple,
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
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: double
                      .infinity, // Make the container fill the width of the page
                  // Adjust horizontal padding
                  child: ElevatedButton(
                    onPressed: submitBooking,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0), // Adjust vertical padding
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
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      child: Text('Go Back to Homepage')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

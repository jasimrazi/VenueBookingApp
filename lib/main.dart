import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:venuebooking/allevents.dart';
import 'package:venuebooking/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VenueBookingApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        buttonTheme: ButtonThemeData(buttonColor: Colors.deepPurple),
        primarySwatch: Colors.deepPurple,
        fontFamily: GoogleFonts.archivo().fontFamily,
        // useMaterial3: true,
      ),
      home: AllEvents(),
    );
  }
}

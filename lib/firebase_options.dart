// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBU4ywCxaUTthAJigspDxkVAgFp7L-ZRvc',
    appId: '1:25725631197:web:29aa7fb3f80a9ad29ef934',
    messagingSenderId: '25725631197',
    projectId: 'venue-booking-91336',
    authDomain: 'venue-booking-91336.firebaseapp.com',
    storageBucket: 'venue-booking-91336.appspot.com',
    measurementId: 'G-L2DRS5MRP3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAad06XOxl9J5Nxu_n2CIdzdQWCiKcPTq4',
    appId: '1:25725631197:android:f1b8c57c0e83187d9ef934',
    messagingSenderId: '25725631197',
    projectId: 'venue-booking-91336',
    storageBucket: 'venue-booking-91336.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlDgSsGpB4W-7n171GinEvslVwtQLl9kI',
    appId: '1:25725631197:ios:4716486936afc3769ef934',
    messagingSenderId: '25725631197',
    projectId: 'venue-booking-91336',
    storageBucket: 'venue-booking-91336.appspot.com',
    iosBundleId: 'com.example.venuebooking',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDlDgSsGpB4W-7n171GinEvslVwtQLl9kI',
    appId: '1:25725631197:ios:fe4466595dea96ae9ef934',
    messagingSenderId: '25725631197',
    projectId: 'venue-booking-91336',
    storageBucket: 'venue-booking-91336.appspot.com',
    iosBundleId: 'com.example.venuebooking.RunnerTests',
  );
}

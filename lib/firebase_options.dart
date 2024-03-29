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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAYU-wOUZleHvwENYc6EC2Qkh7SjcuueJo',
    appId: '1:264990578326:web:6d9fc6bcb85e684e9954b7',
    messagingSenderId: '264990578326',
    projectId: 'chatmessageapp-89b48',
    authDomain: 'chatmessageapp-89b48.firebaseapp.com',
    storageBucket: 'chatmessageapp-89b48.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-_UYBjet95OpRYzZ3AKkV-WnanWoPrGM',
    appId: '1:264990578326:android:34005ac74cbf95639954b7',
    messagingSenderId: '264990578326',
    projectId: 'chatmessageapp-89b48',
    storageBucket: 'chatmessageapp-89b48.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCr8i5GsWn7yigRvZG621OhOPrep2WRXKE',
    appId: '1:264990578326:ios:7068401e8eaa7d3d9954b7',
    messagingSenderId: '264990578326',
    projectId: 'chatmessageapp-89b48',
    storageBucket: 'chatmessageapp-89b48.appspot.com',
    androidClientId: '264990578326-c6uogffth602rdpjb790eh8t4rn64128.apps.googleusercontent.com',
    iosClientId: '264990578326-ufkpjrueii0j0b4gs385mhi38mpphct6.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatmassegeapp',
  );
}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
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
    apiKey: '',
    appId: '1:998648129612:web:499fdb14ec6d01b00c2ce9',
    messagingSenderId: '998648129612',
    projectId: 'c2c-platform-5a1c2',
    authDomain: 'c2c-platform-5a1c2.firebaseapp.com',
    storageBucket: 'c2c-platform-5a1c2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: ',
    appId: '1:998648129612:android:a7f38dc0d83ea71d0c2ce9',
    messagingSenderId: '998648129612',
    projectId: 'c2c-platform-5a1c2',
    storageBucket: 'c2c-platform-5a1c2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '1:998648129612:ios:499fdb14ec6d01b00c2ce9', // Adjusted from web config
    messagingSenderId: '998648129612',
    projectId: 'c2c-platform-5a1c2',
    storageBucket: 'c2c-platform-5a1c2.firebasestorage.app',
    iosBundleId: 'com.example.c2c',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: '',
    appId: '1:998648129612:ios:499fdb14ec6d01b00c2ce9',
    messagingSenderId: '998648129612',
    projectId: 'c2c-platform-5a1c2',
    storageBucket: 'c2c-platform-5a1c2.firebasestorage.app',
    iosBundleId: 'com.example.c2c',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: '',
    appId: '1:998648129612:web:499fdb14ec6d01b00c2ce9',
    messagingSenderId: '998648129612',
    projectId: 'c2c-platform-5a1c2',
    authDomain: 'c2c-platform-5a1c2.firebaseapp.com',
    storageBucket: 'c2c-platform-5a1c2.firebasestorage.app',
  );
}

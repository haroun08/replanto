import 'package:bloc/bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:replanto/simple_bloc_observer.dart';
import 'package:user_repository/user_repository.dart';
import 'package:plant_repository/plant_repository.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      projectId: 'replanto',
      apiKey: 'AIzaSyBVmWtaiF55ydFHc_Xn31Ju8oTm7EqHsGA',
      appId: '1:1051656917820:android:c30932220df6171e728439',
      messagingSenderId: '1051656917820',
      storageBucket: 'replanto.appspot.com',
    ),
  );

  await FirebaseAppCheck.instance.activate();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();
  print('User granted permission: ${settings.authorizationStatus}');

  Bloc.observer = SimpleBlocObserver();

  final plantRepository = FirebasePlantRepo();
  final userRepository = FirebaseUserRepo(
    plantRepo: plantRepository,
  );

  runApp(MyApp(
    userRepository: userRepository,
  ));
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:replanto/pages/Home/HomePage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      projectId: 'replanto',
      apiKey: 'AIzaSyBVmWtaiF55ydFHc_Xn31Ju8oTm7EqHsGA',
      appId: '1:1051656917820:android:c30932220df6171e728439',
      messagingSenderId: '1051656917820',
      storageBucket: 'replanto.appspot.com',
    ),
  );  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Homepage(),
    );
  }
}


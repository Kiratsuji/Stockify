import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stockify/firebase_options.dart';
import 'package:stockify/screens/welcome.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stockify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      home: WelcomeScreen());
  }
}
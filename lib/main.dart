import 'package:flutter/material.dart';
import 'package:menstrual_tracker/screens/home_screen.dart';
import 'package:menstrual_tracker/providers/cycle_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CycleProvider(),
      child: MaterialApp(
        title: 'Cycle Tracker',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
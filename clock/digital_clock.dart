import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:timer_builder/timer_builder.dart';

void main() => runApp(AlarmApp());

class AlarmApp extends StatefulWidget {

  _AlarmAppState createState() => _AlarmAppState();
}

class _AlarmAppState extends State<AlarmApp>{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
              return Text(
                  formatDate(DateTime.now(), [hh, ':', nn, ':', ss, ' ', am]), // add pubspec.yaml the date_format: ^1.0.9
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w600,
                  )
              );
            })
          ],
        )
      )
    );
  }
}

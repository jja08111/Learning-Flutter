import 'package:app_for_blog_posting/sleep_data_chart/sleep_data_chart.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  /// 수면 그래프 테스트 데이터
  ///
  /// 수면량
  final List<double> dataAmount = [5.77, 4.9, 7.75, 4, 4, 4.65, 9.1];
  /// 기상 시간
  final List<double> dataWakeUpTime = [6.3, 12, 8.32, 10.36, 5.4, 5, 6.4];
  /// 날짜
  final List<String> labels = [
    "Mon",
    "Mon",
    "Tue",
    "Wed",
    "Wed",
    "Thu",
    "Fri",
  ];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      color: Color(0xff121212),
      home: Center(
        child: SleepDataChart(
          barColor: Colors.lightBlueAccent,
          dataWakeUpTime: dataWakeUpTime,
          dataAmount: dataAmount,
          labels: labels,
        ),
      ),
    );
  }
}

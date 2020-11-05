import 'sleep_data_charts.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  /// 수면 그래프 테스트 데이터
  ///
  /// 기상 시간
  final List<double> dataWakeUpTime = [8, 10, 11, 8];
  /// 수면량
  final List<double> dataAmount = [8, 9, 7, 5];
  /// 날짜
  final List<String> labels = [
    "10/1",
    "10/2",
    "10/3",
    "10/4",
  ];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Center(
        child: Container(
          child: CustomPaint(
            size: Size(300, 300),
            foregroundPainter: SleepDataChart(
              dataWakeUpTime: dataWakeUpTime,
              dataAmount: dataAmount,
              labels: labels,
            ),
          ),
        ),
      ),
    );
  }
}

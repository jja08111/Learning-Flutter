# Sleep data chart

하루 단위로 수면을 언제 시작해서 끝났는지 보여주는 차트입니다.  
This is chart that show sleep data per day.

[이곳](https://software-creator.tistory.com/23)에서 bar chart코드를 이용하여 제작했습니다. 

# Sample 

![image](/assets/images/sleep_data_chart.png)

# Example

```dart 
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
```

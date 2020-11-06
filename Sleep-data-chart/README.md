# Sleep data chart

하루 단위로 수면을 언제 시작해서 끝났는지 보여주는 차트입니다.  
This is chart that show sleep data per day.

[이곳](https://software-creator.tistory.com/23)에서 bar chart코드를 이용하여 제작했습니다. 

`barColor`, `fontColor`를 커스텀 할 수 있습니다.
You can customize the `barColor`, `fontColor`.

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

  /// Sample data
  final List<double> dataWakeUpTime = [8.4, 10.9, 11.4, 8.2];
  /// 
  final List<double> dataAmount = [8.5, 9.2, 7.4, 5.5];
  /// 
  final List<String> labels = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
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

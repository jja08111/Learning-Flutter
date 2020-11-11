# Sleep data chart

- 하루 단위로 수면을 언제 시작해서 끝났는지 보여주는 차트입니다.  
This is chart that show sleep data per day.

- 기상시간과 수면량이 있으면 차트를 그릴 수 있습니다.

- [이곳](https://software-creator.tistory.com/23)에서 bar chart코드를 이용하여 제작했습니다. 

- `barColor`, `tooltipDuration` 그리고 전체 그래프의 크기를 커스텀 할 수 있습니다.  
You can customize the `barColor`, `tooltipDuration` and size of graph.

- 필요시 데이터 생성 예제 코드를 보며 데이터를 생상하기 바랍니다. 

# Sample 

![image](/assets/images/sleep_data_chart.gif)

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

# update 

## 0.0.1
- 업로드 

## 0.1.1 
- 바를 길게 터치(onLongPressed)하면 수면량을 보이는 툴팁기능 추가 
- 하루에 수면량을 표시하는 바를 2개 이상 추가 가능  
날짜가 겹치면 동일한 x축에 표시 

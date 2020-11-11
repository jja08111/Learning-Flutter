/// This is sample code!!!

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:random_alarm/screens/home_screen/second_screen/components/sleep_data_chart/sleep_data_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:random_alarm/components/color_theme/color_theme.dart';
import 'package:random_alarm/services/db_helper/db_helper.dart';
import 'package:random_alarm/services/db_helper/sleep_data_model.dart';
import 'package:touchable/touchable.dart';

import 'components/chart_painter.dart';

const int ONE_HOUR_TO_MINUTES=60;

const List<String> weekdayKorean = [
  "월", "화", "수", "목", "금", "토", "일",
];

class ReadSleepDataChart extends StatelessWidget {

  List<double> _getDataWakeUpTimeList(List<DailySleepData> list) {
    List<double> result = List();
    int dayCount = 0;
    int idx = 0;
    int previousDay = -1;
    int length = list.length;

    while(idx < length && dayCount < 7) {
      // 가장 뒤의 데이터(최신 데이터)부터 접근한다.
      // 즉, 가장 최신 데이터가 0번 인덱스 부터 시작한다.
      DateTime endTime = DateTime.parse(list[length - idx - 1].endTime);
      result.insert(idx, endTime.hour.toDouble() + endTime.minute.toDouble()/60);
      if(endTime.day != previousDay) {
        previousDay = endTime.day;
        ++dayCount;
      }
      ++idx;
    }
    // 가장 최신 데이터가 오른쪽에 위치할 수 있도록 List 를 reverse 해준다.
    return List<double>.from(result.reversed);
  }

  // 위의 주석과 동일하다.
  List<double> _getDataAmountList(List<DailySleepData> list) {
    List<double> result = List();
    int dayCount = 0;
    int idx = 0;
    int previousDay = -1;
    int length = list.length;

    while(idx < length && dayCount < 7) {
      DateTime endTime = DateTime.parse(list[length - idx - 1].endTime);
      result.insert(idx, list[length - idx - 1].amountMinutes/60);
      if(endTime.day != previousDay) {
        previousDay = endTime.day;
        ++dayCount;
      }
      ++idx;
    }
    return List<double>.from(result.reversed);
  }

  List<String> _getWeekdayList(List<DailySleepData> list) {
    List<String> result = List();
    int dayCount = 0;
    int idx = 0;
    int previousDay = -1;
    int length = list.length;

    while(idx < length && dayCount < 7) {
      DateTime endTime = DateTime.parse(list[length - idx - 1].endTime);
      // weekDay 는 id 의 마지막 자리의 숫자이다.
      result.insert(idx, weekdayKorean[list[length - idx - 1].id % 10 - 1]);
      if(endTime.day != previousDay) {
        previousDay = endTime.day;
        ++dayCount;
      }
      ++idx;
    }
    return List<String>.from(result.reversed);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DBHelper().getAllData(),
      builder: (BuildContext context, AsyncSnapshot<List<DailySleepData>> snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data.isEmpty) {
            return Center(
              child: Text(
                'Empty',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            );
          }
          return SleepDataChart(
            barColor: ColorTheme.label,
            dataWakeUpTime: _getDataWakeUpTimeList(snapshot.data),
            dataAmount: _getDataAmountList(snapshot.data),
            labels: _getWeekdayList(snapshot.data),
          );
        } else {
          return Center(
            child: Text(
              'Loading...',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          );
        }
      },
    );
  }
}

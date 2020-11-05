import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OffsetRange {
  double dx;
  double top;
  double bottom;
  OffsetRange(this.dx, this.top, this.bottom);
}

class SleepDataChart extends CustomPainter {
  static const Color fontColor=Colors.white;

  Color color;
  double textScaleFactorXAxis = 1.0; // x축 텍스트의 비율을 정함.
  double textScaleFactorYAxis = 1.2; // y축 텍스트의 비율을 정함.

  List<double> dataWakeUpTime = [];
  List<double> dataAmount = [];
  List<String> labels = [];
  double bottomPadding = 0.0;
  double leftPadding = 0.0;

  SleepDataChart({
    this.dataWakeUpTime,
    this.dataAmount,
    this.labels,
    this.color = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    setTextPadding(size); // 텍스트를 공간을 미리 정함.

    List<OffsetRange> coordinates = getCoordinates(size);

    drawXLabels(canvas, size, coordinates);
    drawYLabels(canvas, size, coordinates);
    drawBar(canvas, size, coordinates);
    drawBoxLines(canvas, size, coordinates);
  }

  void setTextPadding(Size size) {
    bottomPadding = size.height / 10; // 세로 크기의 1/10만큼만 텍스트 패딩을 줌
    leftPadding = size.width / 10; // 가로 길이의 1/10만큼 텍스트 패딩을 줌
  }

  void drawBar(Canvas canvas, Size size, List<OffsetRange> coordinates) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    double barWidthMargin = (size.width * 0.09); // 막대 그래프가 겹치지 않게 간격을 줌.
    double leftPadding=5.0;

    for (var index = 0; index < coordinates.length; index++) {
      OffsetRange offset = coordinates[index];
      double left = offset.dx + leftPadding;
      double right = offset.dx + leftPadding + barWidthMargin; // 간격만큼 가로로 이동
      double top = offset.top;
      double bottom = offset.bottom; // 텍스트 크기만큼 패딩을 빼줘서, 텍스트와 겹치지 않게 함.

      Rect rect = Rect.fromLTRB(right, top, left, bottom);
      canvas.drawRect(rect, paint);
    }
  }

  // X축 텍스트(레이블)을 그림.
  void drawXLabels(Canvas canvas, Size size, List<OffsetRange> coordinates) {
    double fontSize = calculateFontSize(labels[0], size, xAxis: true); // 화면 크기에 유동적으로 폰트 크기를 계산함.

    for (int index = 0; index < labels.length; index++) {
      TextSpan span = TextSpan(
        style: TextStyle(
            color: fontColor,
            fontSize: fontSize,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400),
        text: labels[index],
      );

      TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();

      OffsetRange offset = coordinates[index];
      double dx = offset.dx;
      double dy = size.height - tp.height;

      tp.paint(canvas, Offset(dx, dy));
    }
  }

  _getTopPosition(double bottom, double amount) {
    return (24.0-bottom)+amount;
  }

  _getTopIndex() {
    int topIdx=0;
    double top=0.0;
    for(int i=0;i<dataAmount.length;++i) {
      double candidate=_getTopPosition(dataWakeUpTime[i], dataAmount[i]);
      if(top<candidate) {
        top=candidate;
        topIdx=i;
      }
    }
    return topIdx;
  }

  bool _lowestBarIsDotClock(int index) {
    return dataWakeUpTime[index].ceilToDouble() == dataWakeUpTime[index];
  }

  /// pivot 에서 duration 만큼 뒤로 시간이 흐르면 나오는 시간
  _getClockDiff(var pivot, var duration) {
    var ret=pivot-duration;
    return ret + (ret<0 ? 24 : 0);
  }

  String convert12StringFormat(int hours) {
    return (hours==0 || hours==12 ? 12 : hours%12 ).toString() + (hours~/12 > 0 ? ' PM' : ' AM');
  }

  // Y축 텍스트(레이블)을 그림. 최저값과 최고값을 Y축에 표시함.
  void drawYLabels(Canvas canvas, Size size, List<OffsetRange> coordinates) {
    int indexOfMax = _getTopIndex();
    int indexOfMin = 0;

    double topY = 0;
    double bottomY = coordinates[0].bottom;

    for (int index = 0; index < coordinates.length; index++) {
      double bottom = coordinates[index].bottom;
      /// y 축에서 가장 멀리 떨어져야 제일 아래에 위치한다.
      if (bottomY < bottom) {
        bottomY = bottom;
        indexOfMin = index;
      }
    }
    bottomY = size.height - bottomPadding;

    int topTime=_getClockDiff(dataWakeUpTime[indexOfMax],dataAmount[indexOfMax]).toInt(); 
    int bottomTime=dataWakeUpTime[indexOfMin].toInt() + (_lowestBarIsDotClock(indexOfMin) ? 0 : 1);

    double fontSize = 16;// calculateFontSize(maxValue, size, xAxis: false);

    int indexSize=_getClockDiff(bottomTime,topTime);
    double gabY=(bottomY-topY)/(indexSize);

    int time = topTime;
    double posY = topY;
    /// 2칸 간격으로 좌측 레이블 표시
    while(time != bottomTime) {
      if(time >= 24)
        time %= 24;
      drawYText(canvas, convert12StringFormat(time), fontSize, posY);
      drawHorizontalLine(canvas, size, coordinates, posY);

      time+=1;
      posY += gabY;
    }
    drawYText(canvas, convert12StringFormat(time), fontSize, posY);
  }

  // 화면 크기에 비례해 폰트 크기를 계산.
  double calculateFontSize(String value, Size size, {bool xAxis}) {
    int numberOfCharacters = value.length; // 글자수에 따라 폰트 크기를 계산하기 위함.
    double fontSize = (size.width / numberOfCharacters) / dataWakeUpTime.length; // width 가 600일 때 100글자를 적어야 한다면, fontSize는 글자 하나당 6이어야겠죠.

    if (xAxis) {
      fontSize *= textScaleFactorXAxis;
    } else {
      fontSize *= textScaleFactorYAxis;
    }

    return fontSize;
  }

  void drawHorizontalLine(Canvas canvas, Size size, List<OffsetRange> coordinates, double dy) {
    Paint paint = Paint()
      ..color = fontColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.5;

    double startX=coordinates[0].dx;
    double dashWidth=5.0, dashSpace = 9.0;
    Path path = Path();
    path.moveTo(startX, dy);

    path.lineTo(size.width, dy);
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, dy), Offset(startX + dashSpace-dashWidth, dy), paint);
      startX += dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  // x축과 y축을 구분하는 선을 긋습니다.
  void drawBoxLines(Canvas canvas, Size size, List<OffsetRange> coordinates) {
    Paint paint = Paint()
      ..color = fontColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    double bottom = size.height - bottomPadding;
    double left = coordinates[0].dx;

    Path path = Path();
    path.moveTo(left, 0);
    path.lineTo(left, bottom);
    path.lineTo(size.width, bottom);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  void drawYText(Canvas canvas, String text, double fontSize, double y) {

    TextSpan span = TextSpan(
      style: TextStyle(
          fontSize: fontSize,
          color: fontColor,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400),
      text: text,
    );

    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);

    tp.layout();
    double x=(text.length*-8).toDouble() + 8.0;

    Offset offset = Offset(x, y - fontSize/2);
    tp.paint(canvas, offset);
  }

  List<OffsetRange> getCoordinates(Size size) {
    List<OffsetRange> coordinates = [];

    int maxIdx=_getTopIndex();

    double width = size.width - leftPadding;
    double minBarWidth = width / dataWakeUpTime.length;

    /// 제일 아래에 붙은 바가 정각이 아닌 경우 올려 바를 그린다.
    int pivotBottom=dataWakeUpTime.reduce(max).ceil();

    /// bar 의 아래 부분 + 윗 부분의 크기 합 이 역시 정각이 아니면 올림한다.
    int pivotTop = ((pivotBottom - dataWakeUpTime[maxIdx]) + dataAmount[maxIdx]).ceil();

    //print(pivot);
    for (var index = 0; index < dataWakeUpTime.length; index++) {
      double left = minBarWidth * (index) + leftPadding; // 그래프의 가로 위치를 정합니다.
      /// 좌측 라벨이 아래로 갈수록 시간이 흐르는 것을 표현하기 위해
      /// 큰 시간 값과 현재 시간의 차를 구한다.
      double normalizedBottom = (pivotBottom - dataWakeUpTime[index]) / pivotTop; // 그래프의 높이가 [0~1] 사이가 되도록 정규화 합니다.
      /// [normalizedBottom] 에서 [gap]칸 만큼 위로 올린다.
      double normalizedTop = normalizedBottom + (dataAmount[index]) / pivotTop;

      double height = size.height - bottomPadding; // x축에 표시되는 글자들과 겹치지 않게 높이에서 패딩을 제외합니다.
      double bottom = height - normalizedBottom * height; // 정규화된 값을 통해 높이를 구해줍니다.
      double top = height - normalizedTop * height;

      OffsetRange offset = OffsetRange(left, top, bottom);
      coordinates.add(offset);
    }

    return coordinates;
  }

  @override
  bool shouldRepaint(SleepDataChart old) {
    return old.dataWakeUpTime != dataWakeUpTime;
  }
}

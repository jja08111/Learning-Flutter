import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

class OffsetRange {
  double dx;
  double topY;
  double bottomY;
  OffsetRange(this.dx, this.topY, this.bottomY);
}

// 이 코드는 1시 ~ 24시로 흐르는 시간의 흐름을 유념하여야 한다.
class ChartPainter extends CustomPainter {

  final void Function({
  BuildContext context,
  double amount,
  dynamic left, dynamic top,
  }) showTooltipCallback;

  final BuildContext context;
  final Color barColor;
  final Color fontColor;
  final double textScaleFactorXAxis = 1.0; // x축 텍스트의 비율을 정함.
  final double textScaleFactorYAxis = 1.2; // y축 텍스트의 비율을 정함.
  /// make chart using this pivot value
  final int topHour;

  List<double> dataWakeUpTime = [];
  List<double> dataAmount = [];
  List<String> labels = [];

  double barWidth = 0.0; // 막대 그래프가 겹치지 않게 간격을 줌.
  double bottomMargin = 0.0; // 그래프의 아래 날짜 레이블이 들어갈 간격
  double leftMargin = 0.0; // 그래프의 왼쪽 시간 레이블이 들어갈 간격
  double paddingForAlignedBar = 0.0; // 바를 중앙에 정렬하기 위한 간격

  ChartPainter({
    Key key,
    @required this.showTooltipCallback,
    @required this.context,
    @required this.dataWakeUpTime,
    @required this.dataAmount,
    @required this.labels,
    this.topHour = 17,
    this.barColor = Colors.blue,
    this.fontColor = Colors.white38,
  }) {
    assert(context!=null);
    assert(dataWakeUpTime.length == dataAmount.length);
    assert(dataAmount.length == labels.length);
  }

  @override
  void paint(Canvas canvas, Size size) {
    setMarginAndPadding(size); // 텍스트를 공간을 미리 정함.

    List<OffsetRange> coordinates = getCoordinates(size);

    drawXLabels(canvas, size, coordinates);
    drawYLabels(canvas, size, coordinates);
    drawBar(canvas, size, coordinates);
    //drawBoxLines(canvas, size, coordinates);
  }

  /// 기준 시간을 이용하여 시간을 변환한다.
  /// 기준 시간을 기준으로 시간을 아래로 나열된다.
  ///
  /// 예를 들어 17시가 기준이라고 할 때 3시가 입력으로 들어오면 27이 반환된다.
  _convertUsingCuttingHour(var value) {
    return value + (value < topHour ? 24.0 : 0);
  }

  void setMarginAndPadding(Size size) {
    barWidth = (size.width * 0.1);
    bottomMargin = size.height / 10; // 세로 크기의 1/10만큼만 텍스트 공간을 줌
    leftMargin = size.width / 10; // 가로 길이의 1/10만큼 텍스트 공간을 줌
    // 바의 위치를 가운데로 정렬하기 위한 [padding]
    paddingForAlignedBar = (size.width - leftMargin) / (getIndexSizeOfHorizontal())/2 - barWidth/2;
  }

  void drawBar(Canvas canvas, Size size, List<OffsetRange> coordinates) {
    // 터치 가능한 캔버스 형성
    TouchyCanvas touchyCanvas = TouchyCanvas(context, canvas);
    Paint paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < coordinates.length; index++) {
      final OffsetRange offset = coordinates[index];

      final double left = paddingForAlignedBar + offset.dx;
      final double right = paddingForAlignedBar + offset.dx + barWidth; // 간격만큼 가로로 이동
      final double top = offset.topY;
      final double bottom = offset.bottomY; // 텍스트 크기만큼 패딩을 빼줘서, 텍스트와 겹치지 않게 함.

      final RRect rect = RRect.fromLTRBR(left, top, right, bottom, Radius.circular(8.0));

      touchyCanvas.drawRRect(rect, paint,
        // 바를 길게 누르면 화면에 수면량을 표시한다.
        onLongPressStart: (_) => showTooltipCallback(
          context: context,
          amount: dataAmount[index],
          left: left,
          top: top,
        ),
      );
    }
  }

  // X축 텍스트(레이블)을 그림.
  void drawXLabels(Canvas canvas, Size size, List<OffsetRange> coordinates) {
    int minLength=labels[0].length;
    for(int i=1;i<labels.length;++i) {
      minLength=min(minLength,labels[i].length);
    }

    for (int index = 0; index < labels.length; index++) {
      // 뒤의 [labels]와 동일하다면 건너뛴다.
      if(index+1 < labels.length && labels[index] == labels[index+1])
        continue;

      TextSpan span = TextSpan(
        text: labels[index],
        style: TextStyle(
          color: fontColor,
          fontSize: 14,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
        ),
      );

      TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout();

      OffsetRange offset = coordinates[index];

      // 날짜의 길이에 따라 위치를 다르게 한다.
      double dx = offset.dx + paddingForAlignedBar + barWidth/2-6;
      double dy = size.height - tp.height;

      tp.paint(canvas, Offset(dx, dy));
    }
  }

  /// [topHour]을 기준으로 아래쪽에 배치하였을때 바의 상단 부분 위치를 반환
  /// 작을 수록 가장 위에 위치한 값으로 여겨야 한다.
  _getTopPosition(double bottom, double amount) {
    return _convertUsingCuttingHour(bottom-amount);
  }

  _getTopIndex() {
    int topIdx = 0;
    double topPos = 1000.0;
    for(int i = 0; i < dataAmount.length; ++i) {
      double candidate = _getTopPosition(dataWakeUpTime[i], dataAmount[i]);
      // cuttingHour 을 기준으로 아래쪽에 가장 가까이 위치한 값이 top 이 된다.
      if(topPos > candidate) {
        topPos = candidate;
        topIdx = i;
      }
    }
    return topIdx;
  }

  _getBottomIndex() {
    int bottomIdx = 0;
    double bottomPos = 0.0;
    for(int i = 0; i < dataAmount.length; ++i) {
      double candidate = _convertUsingCuttingHour(dataWakeUpTime[i]);
      // cuttingHour 을 기준으로 아래쪽에 가장 멀리 위치한 값이다.
      if(bottomPos < candidate) {
        bottomPos = candidate;
        bottomIdx = i;
      }
    }

    return bottomIdx;
  }

  bool _isLowestBarDotClock(int index) {
    return dataWakeUpTime[index].ceilToDouble() == dataWakeUpTime[index];
  }

  // pivot 에서 duration 만큼 이전으로 시간이 흐르면 나오는 시간
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
    double bottomY = coordinates[0].bottomY;

    for (int index = 0; index < coordinates.length; index++) {
      double bottom = coordinates[index].bottomY;
      // y 축에서 가장 멀리 떨어져야 제일 아래에 위치한다.
      if (bottomY < bottom) {
        bottomY = bottom;
        indexOfMin = index;
      }
    }
    bottomY = size.height - bottomMargin;

    // 가장 위에 다다른 바의 위쪽 부분 시간을 구한다.
    // 아래 위치(기상시간)에 수면량만큼 뒤로 시간을 보내 구한다.
    int topTime=_getClockDiff(dataWakeUpTime[indexOfMax],dataAmount[indexOfMax]).toInt();
    // 가장 아래에 있는 바의 시간(기상 시간)을 구한다.
    // 만약 기상 시간이 정각이 아니면 1시간을 더한다.
    int bottomTime=dataWakeUpTime[indexOfMin].toInt() + (_isLowestBarDotClock(indexOfMin) ? 0 : 1);
    double fontSize = 13;// calculateFontSize(maxValue, size, xAxis: false);

    int indexSize=_getClockDiff(bottomTime,topTime);
    double gabY=(bottomY-topY)/(indexSize);

    int time = topTime;
    double posY = topY;

    // 2칸 간격으로 좌측 레이블 표시
    while(true) {
      if(time >= 24)
        time %= 24;
      // 맨 위부터 2시간 단위로 시간을 그린다.
      if(time % 2 == topTime % 2)
        drawYText(canvas, convert12StringFormat(time), fontSize, posY);
      // 선을 그린다.
      drawHorizontalLine(canvas, size, coordinates, posY);

      // 맨 아래에 도달한 경우
      if(time == bottomTime % 24)
          break;

      time+=1;
      posY += gabY;
    }
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
    canvas.drawLine(Offset(startX,dy), Offset(size.width, dy), paint);

    // 점선 코드
    //double dashWidth=5.0, dashSpace = 9.0;
    //while (startX < size.width) {
    //  canvas.drawLine(Offset(startX, dy), Offset(startX + dashSpace-dashWidth, dy), paint);
    //  startX += dashSpace;
    //}
    //
  }

  void drawYText(Canvas canvas, String text, double fontSize, double y) {
    TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        color: fontColor,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
      ),
    );

    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);

    tp.layout();
    // 문자열을 라인에 맞춰 정렬한다.
    double x = (text.length*-7).toDouble() + 19.0;
    // 마찬가지로 문자열을 라인에 맞춰 정렬한다.
    Offset offset = Offset(x, y - fontSize/2);
    tp.paint(canvas, offset);
  }

  int getIndexSizeOfHorizontal() {
    int ret=labels.length;
    for(int i = 0; i < labels.length-1; ++i) {
      if(labels[i]==labels[i+1])
        --ret;
    }
    return ret;
  }

  List<OffsetRange> getCoordinates(Size size) {
    List<OffsetRange> coordinates = [];

    // 제일 상단에 도달한 바의 인덱스를 얻는다.
    int maxIdx=_getTopIndex();
    int minIdx=_getBottomIndex();

    double width = size.width - leftMargin;
    double intervalOfBars = width / getIndexSizeOfHorizontal();

    // 제일 아래에 붙은 바가 정각이 아닌 경우 올려 바를 그린다.
    int pivotBottom = _convertUsingCuttingHour(dataWakeUpTime[minIdx]).ceil();
    // 가장 위에 도달한 바의 아래 빈 공간 부분과 바의 높이를 더한다.
    // 즉 가장 높은 바의 상단부 높이를 구한다.
    // 이 값은 정규화시 기준값이 된다. 이 역시 정각이 아니면 올림한다.
    int pivotHeight = (pivotBottom - _convertUsingCuttingHour(dataWakeUpTime[maxIdx])
        + dataAmount[maxIdx]).ceil();

    final int length = dataWakeUpTime.length;
    int xIndexCount = 0;
    for (var index = 0; index < length; index++) {

      double left = leftMargin + intervalOfBars*(xIndexCount);
      // [labels]가 달라야 오른쪽으로 한 칸 이동한다.
      if(index+1 < length && labels[index] != labels[index+1])
        ++xIndexCount;
      // 좌측 라벨이 아래로 갈수록 시간이 흐르는 것을 표현하기 위해
      // 큰 시간 값과 현재 시간의 차를 구한다.
      double normalizedBottom = (pivotBottom -
          _convertUsingCuttingHour(dataWakeUpTime[index])) / pivotHeight; // 그래프의 높이가 [0~1] 사이가 되도록 정규화 합니다.
      // [normalizedBottom] 에서 [gap]칸 만큼 위로 올린다.
      double normalizedTop = normalizedBottom + (dataAmount[index]) / pivotHeight;

      double height = size.height - bottomMargin; // x축에 표시되는 글자들과 겹치지 않게 높이에서 패딩을 제외합니다.
      double bottom = height - normalizedBottom * height; // 정규화된 값을 통해 높이를 구해줍니다.
      double top = height - normalizedTop * height;

      OffsetRange offset = OffsetRange(left, top, bottom);
      coordinates.add(offset);
    }

    return coordinates;
  }

  @override
  bool shouldRepaint(ChartPainter old) {
    return old.dataWakeUpTime != dataWakeUpTime;
  }
}

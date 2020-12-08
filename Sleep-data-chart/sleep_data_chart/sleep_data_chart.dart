import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

import 'components/context_utils.dart';
import 'components/chart_painter.dart';
import 'components/duration_tooltip_overlay.dart';

class SleepDataChart extends StatefulWidget {
  SleepDataChart({
    this.width = 350,
    this.height = 320,
    this.barColor = Colors.blueAccent,
    @required this.dataWakeUpTime,
    @required this.dataAmount,
    @required this.labels,
    this.tooltipDuration = const Duration(seconds: 3),
    this.topHour,
  }) : assert(dataAmount.length == dataWakeUpTime.length),
        assert(dataWakeUpTime.length == labels.length);

  /// 그래프의 너비
  final double width;

  /// 그래프의 높이
  final double height;

  /// 바의 색상
  final Color barColor;

  /// 기상시간 리스트
  final List<double> dataWakeUpTime;

  /// 수면량 리스트
  ///
  /// 0인 값을 이용하여 해당 요일이 비어있음을 표시할 수 있다.
  final List<double> dataAmount;

  /// 그래프 x축 방향 레이블
  final List<String> labels;

  /// 그래프 클릭시 나오는 툴팁의 지속시간
  final Duration tooltipDuration;

  /// The pivot value that top hour of graph's y axis.
  ///
  /// Automatically calculate this value if it's null.
  /// Manually customize this value If the chart of graph interval is too wide.
  /// It's start 1, end 24.
  final int topHour;

  @override
  _SleepDataChartState createState() => _SleepDataChartState();
}

class _SleepDataChartState extends State<SleepDataChart> with TickerProviderStateMixin {
  static const Duration _fadeInDuration = Duration(milliseconds: 150);
  static const Duration _fadeOutDuration = Duration(milliseconds: 75);

  /// 툴팁을 띄우기 위해 사용한다.
  OverlayEntry _overlayEntry;
  /// 툴팁이 떠있는 시간을 정한다.
  Timer _tooltipHideTimer;
  /// 툴팁의 fadeIn out 애니메이션을 다룬다.
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
      vsync: this,
    );
    // Listen to global pointer events so that we can hide a tooltip immediately
    // if some other control is clicked on.
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
    _processDataAmountList();
  }

  /// a에서 b로 흐른 시간을 구하거나, a에서 b만큼 이전으로 흐른 시간을 구한다.
  double _getHourDiff(double a, double b) {
    double c = a - b;
    if(c <= 0) {
      return 24.0 + c;
    }
    return c;
  }

  /// 두 시간 중 어느 쪽이 더 빠른지 판단한다.
  /// a가 빠르면 true, b가 빠르면 false 반환한다.
  bool _compareHours(double a, double b) {
    return _getHourDiff(a, b) > 12 ? true : false;
  }

  /// 빈 데이터인 경우의 bar 위치를 적절하게 생성한다.
  double _getEmptyHourPosition() {
    int idx = 0;
    for(int i=0;i<widget.dataAmount.length;++i) {
      if(widget.dataAmount[i] > 0) {
        idx = i;
        break;
      }
    }
    return widget.dataWakeUpTime[idx];
  }

  void _processDataAmountList() {
    final emptyHourPosition = _getEmptyHourPosition();
    for(int i=0;i<widget.dataAmount.length;++i) {
      if(widget.dataAmount[i] == 0) {
        widget.dataWakeUpTime[i] = emptyHourPosition;
      }
    }
  }

  int get _topHour {
    final length = widget.dataWakeUpTime.length;
    int resultIdx = 0;

    for(int i = 0; i < length; ++i) {
      final firstIdx = i;
      int idx = -1;
      // 동일한 요일 데이터일때 간격이 제일 넓은 구간의 아래 부분 기상값 중
      // 제일 빠른 기상 값을 가진 요일의 데이터가 기준이 된다.
      double maxInterval = 0.0;
      // 같은 요일 데이터 중 간격이 제일 넓은 부분의 아래 데이터를 찾는다.
      while(i < length) {
        final int lo = i;
        final int hi = (i + 1) % length;
        // 요일이 다른 경우
        if(widget.labels[lo] != widget.labels[hi]) {
          double candidateDiff = _getHourDiff(
              _getHourDiff(widget.dataWakeUpTime[firstIdx], widget.dataAmount[firstIdx]), widget.dataWakeUpTime[lo]);
          if(maxInterval < candidateDiff) {
            maxInterval = candidateDiff;
            idx = firstIdx;
          }
          break;
        }
        double candidateDiff = _getHourDiff(
            _getHourDiff(widget.dataWakeUpTime[hi], widget.dataAmount[hi]), widget.dataWakeUpTime[lo]);
        if(maxInterval < candidateDiff) {
          maxInterval = candidateDiff;
          idx = hi;
        }
        ++i;
      }
      // 기상 시간이 더 빠른 것을 이용한다.
      if(_compareHours(
          _getHourDiff(widget.dataWakeUpTime[idx], widget.dataAmount[idx]),
          _getHourDiff(widget.dataWakeUpTime[resultIdx], widget.dataAmount[resultIdx]))
      ) {
        resultIdx = idx;
      }
    }
    return _getHourDiff(widget.dataWakeUpTime[resultIdx], widget.dataAmount[resultIdx]).floor();
  }

  void _handlePointerEvent(PointerEvent event) {
    if (_overlayEntry == null)
      return;
    if (event is PointerDownEvent)
      removeEntry();
  }

  /// 해당 바(bar)를 눌렀을 경우 툴팁을 띄운다.
  ///
  /// 위치는 x축 방향 left, y축 방향 top 만큼 떨어진 위치이다.
  void showTooltipCallback({
    BuildContext context,
    double amount,
    dynamic left,
    dynamic top,
  }) {
    // 현재 위젯의 위치를 얻는다.
    final pivotOffset = ContextUtils.getOffsetFromContext(context);
    removeEntry();
    _controller.forward();
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        // 바 위에 정확히 [tooltip]을 띄운다.
        top: top + pivotOffset.dy - 60,
        left: left + pivotOffset.dx - 25,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.fastOutSlowIn,
          ),
          child: DurationTooltipOverlay(durationHour: amount),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry);
    _tooltipHideTimer = Timer(widget.tooltipDuration, removeEntry);
  }

  /// 현재 존재하는 툴팁을 제거한다.
  void removeEntry() {
    _tooltipHideTimer?.cancel();
    _tooltipHideTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    removeEntry();
    _controller.dispose();
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handlePointerEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CanvasTouchDetector(
        builder: (context) => CustomPaint(
          size: Size(widget.width, widget.height),
          painter: ChartPainter(
            context: context,
            showTooltipCallback: showTooltipCallback,
            dataWakeUpTime: widget.dataWakeUpTime,
            dataAmount: widget.dataAmount,
            labels: widget.labels,
            barColor: widget.barColor,
            topHour: widget.topHour ?? _topHour,
          ),
        ),
      ),
    );
  }
}

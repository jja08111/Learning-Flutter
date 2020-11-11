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
  });

  /// 그래프의 너비
  final double width;

  /// 그래프의 높이
  final double height;

  /// 바의 색상
  final Color barColor;

  /// 기상시간 리스트
  final List<double> dataWakeUpTime;

  /// 수면량 리스트
  final List<double> dataAmount;

  /// 그래프 x축 방향 레이블
  final List<String> labels;

  /// 그래프 클릭시 나오는 툴팁의 지속시간
  final Duration tooltipDuration;

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
  initState() {
    super.initState();
    _controller = AnimationController(
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
      vsync: this,
    );
    // Listen to global pointer events so that we can hide a tooltip immediately
    // if some other control is clicked on.
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
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
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'tooltip_shape_border.dart';

class DurationTooltipOverlay extends StatelessWidget {
  const DurationTooltipOverlay({
    this.durationHour,
  });

  final double durationHour;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0x00ffffff),
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: TooltipShapeBorder(arrowArc: 0.3),
          shadows: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: SizedBox(
          width: 84,
          height: 44,
          child: Center(
            child: Text(
              _formattingSleepAmount(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formattingSleepAmount() {
    return _getHour() + _getMinutes();
  }

  int _ceilMinutes() {
    double decimal = durationHour - durationHour.toInt();
    return  (decimal*60 + 0.01).toInt() == 60 ? 1 : 0;
  }

  String _getMinutes() {
    double decimal = durationHour - durationHour.toInt();
    // 3.99와 같은 무한소수를 고려한다.
    int minutes = (decimal*60 + 0.01).toInt() % 60;
    return  minutes==0 ? '' : ' ${minutes}m';
  }

  String _getHour() {
    return '${durationHour.toInt() + _ceilMinutes()}h';
  }
}

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Display extends StatelessWidget {
  final List<List<double>> data;
  final Color color;
  const Display(this.data, this.color, {Key? key}) : super(key: key);

  static final axis = NumericAxis(
      crossesAt: 0,
      axisLine: const AxisLine(color: Colors.white70, width: 2),
      majorTickLines: const MajorTickLines(color: Colors.white70),
      minimum: -4,
      maximum: 4,
      interval: 1);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryYAxis: axis,
      primaryXAxis: axis,
      series: [
        LineSeries(
            dataSource: data,
            color: color,
            xValueMapper: (List<double> l, _) => l[0],
            yValueMapper: (List<double> l, _) => l[1],
            animationDuration: 0)
      ],
    );
  }
}

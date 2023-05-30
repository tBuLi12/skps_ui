import 'package:flutter/material.dart';
import 'package:skps_ui/channel_buttons.dart';

class Density {
  final double secPerDiv;
  final double voltPerDiv;
  const Density(this.secPerDiv, this.voltPerDiv);
  Density copyWith({double? secs, double? volts}) {
    return Density(secs ?? secPerDiv, volts ?? voltPerDiv);
  }
}

class DivPickers extends StatelessWidget {
  final List<Density> densities;
  final void Function(int, Density) setDensity;
  const DivPickers(this.densities, this.setDensity, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (var i = 0; i < 4; ++i)
        DivPicker(
            densities[i], (density) => setDensity(i, density), channelColors[i])
    ]);
  }
}

const timeDivs = [10, 1, 0.1, 0.01];
const voltDivs = [10, 4, 1, 0.4, 0.1];

class DivPicker extends StatelessWidget {
  final Density density;
  final void Function(Density) setDensity;
  final Color color;
  const DivPicker(this.density, this.setDensity, this.color, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        DivPickerMenu(color, "s/div", density.secPerDiv, timeDivs,
            (val) => setDensity(density.copyWith(secs: val.toDouble()))),
        DivPickerMenu(color, "V/div", density.voltPerDiv, voltDivs,
            (val) => setDensity(density.copyWith(volts: val.toDouble()))),
      ]),
    );
  }
}

class DivPickerMenu extends StatelessWidget {
  const DivPickerMenu(
    this.color,
    this.label,
    this.value,
    this.values,
    this.setValue, {
    Key? key,
  }) : super(key: key);

  final Color color;
  final num value;
  final String label;
  final List<num> values;
  final void Function(num) setValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color.fromARGB(255, 50, 50, 50),
        underline: Container(height: 2, color: color),
        value: value,
        items: [
          for (var div in timeDivs)
            DropdownMenuItem(
              value: div,
              child: Text('$div $label'),
            )
        ],
        onChanged: (num? val) {
          if (val != null) {
            setValue(val);
          }
        });
  }
}

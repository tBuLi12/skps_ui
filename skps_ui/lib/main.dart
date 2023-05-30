import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skps_ui/channel_buttons.dart';
import 'package:skps_ui/connection.dart';
import 'package:skps_ui/display.dart';
import 'package:skps_ui/div_pickers.dart';
import 'package:skps_ui/trigger_modes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: Oscilloscope(title: 'Oscilloscope'),
    );
  }
}

class Oscilloscope extends StatefulWidget {
  const Oscilloscope({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Oscilloscope> createState() => _OscilloscopeState();
}

class _OscilloscopeState extends State<Oscilloscope> {
  var conn = Connection(1, true);
  List<List<double>> data = [
    [1, 2],
    [2, 3],
    [3, 1],
    [4, 0],
    [5, -3],
  ];
  int channel = 0;
  String triggerMode = "auto";
  StreamSubscription<List<double>>? triggerSubs;
  List<Density> channelDensities = List.filled(4, const Density(1, 1));

  void setChannel(int chan) {
    setState(() => channel = chan);
  }

  void setTriggerMode(String mode) {
    setState(() => triggerMode = mode);
  }

  void setDensity(int chan, Density density) {
    setState(() {
      channelDensities[chan] = density;
      conn.secsPerDiv = channelDensities[channel].secPerDiv;
      reset();
    });
  }

  void listenToTriggers() {
    triggerSubs = conn.getTriggers().listen((vList) {
      setState(() {
        data = [
          for (var i = 0; i < vList.length; ++i)
            [
              (i * 8 / vList.length) - 4,
              vList[i] / channelDensities[channel].voltPerDiv
            ]
        ];
      });
    });
  }

  void reset() {
    triggerSubs?.cancel();
    listenToTriggers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 4, 84, 63),
        actions: [
          const Center(child: Text('MODE:')),
          TriggerPicker(triggerMode, setTriggerMode),
          ChannelButtons(channel, setChannel)
        ],
      ),
      body: Row(children: [
        Expanded(child: Display(data, channelColors[channel])),
        DecoratedBox(
          decoration: BoxDecoration(color: Colors.grey.shade800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DivPickers(channelDensities, setDensity),
          ),
        )
      ]),
      backgroundColor: Colors.black38,
    );
  }

  @override
  void initState() {
    listenToTriggers();
    super.initState();
  }
}

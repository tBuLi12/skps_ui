import 'package:flutter/material.dart';

class ChannelButtons extends StatelessWidget {
  final void Function(int) setChannel;
  final int channel;

  const ChannelButtons(this.channel, this.setChannel, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
              4, (i) => ChannelButton(i, i == 3, channel, setChannel))),
    );
  }
}

const channelColors = [
  Colors.yellow,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.red
];
final disabledChannelColors = [
  for (var color in channelColors)
    HSLColor.fromColor(color).withLightness(0.2).toColor()
];

class ChannelButton extends StatelessWidget {
  final bool last;
  final int index;
  final int active;
  final void Function(int) setChannel;
  const ChannelButton(this.index, this.last, this.active, this.setChannel,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rightRadius = last ? const Radius.circular(4) : Radius.zero;
    final leftRadius = index == 0 ? const Radius.circular(4) : Radius.zero;
    return ElevatedButton(
      onPressed: () => setChannel(index),
      style: ElevatedButton.styleFrom(
          primary:
              (active == index ? channelColors : disabledChannelColors)[index],
          onPrimary: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                  left: leftRadius, right: rightRadius))),
      child: Text('CH${index + 1}'),
    );
  }
}

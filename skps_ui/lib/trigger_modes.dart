import 'package:flutter/material.dart';

class TriggerPicker extends StatelessWidget {
  final void Function(String) setMode;
  final String mode;
  const TriggerPicker(this.mode, this.setMode, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 30, left: 10),
      child: DropdownButton(
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color.fromARGB(255, 50, 50, 50),
          value: mode,
          alignment: Alignment.center,
          items: [
            for (var mode in ["auto", "normal", "single"])
              DropdownMenuItem(
                value: mode,
                child: Text(mode),
              )
          ],
          onChanged: (String? md) {
            if (md != null) {
              setMode(md);
            }
          }),
    );
  }
}

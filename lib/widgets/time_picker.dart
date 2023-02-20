import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final String label;
  final Function callback;
  bool enabled;
  int? hourValue;
  int? minuteValue;
  TimePicker(this.label, this.callback, {super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [Text(label)],
        ),
        Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hour"),
                DropdownButtonFormField(
                    items: List<int>.generate(24, (i) => i + 1)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem(
                          value: value - 1,
                          child: Text((value - 1).toString()));
                    }).toList(),
                    onChanged: !enabled
                        ? null
                        : (int? value) {
                            hourValue = value;
                            callback("$hourValue:$minuteValue");
                          }),
              ],
            )),
            const Text(":"),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Minute"),
                DropdownButtonFormField(
                    items: List<int>.generate(12, (i) => i * 5, growable: false)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem(
                          value: value, child: Text(value.toString()));
                    }).toList(),
                    onChanged: !enabled
                        ? null
                        : (int? value) {
                            minuteValue = value;
                            callback("$hourValue:$minuteValue");
                          }),
              ],
            ))
          ],
        )
      ],
    );
  }
}

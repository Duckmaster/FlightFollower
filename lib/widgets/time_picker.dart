import 'package:flutter/material.dart';

/// Custom widget for picking a time with drop down menus
class TimePicker extends StatelessWidget {
  final String label;
  final Function callback;
  bool enabled;
  int? hourValue;
  int? minuteValue;
  String? Function(int? value)? validator;
  String? time;
  TimePicker(this.label, this.callback,
      {super.key, this.validator, this.time, this.enabled = true}) {
    if (time != null) {
      List<String> parts = time!.split(":");
      hourValue = int.parse(parts[0]);
      minuteValue = int.parse(parts[1]);
    }
  }

  String _prefixWithNaught(String value) {
    if (value.length == 1) {
      return "0$value";
    }
    return value;
  }

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
                          child:
                              Text(_prefixWithNaught((value - 1).toString())));
                    }).toList(),
                    onChanged: !enabled
                        ? null
                        : (int? value) {
                            hourValue = value;
                            callback("$hourValue:$minuteValue");
                          },
                    validator: validator,
                    value: hourValue),
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
                          value: value,
                          child: Text(_prefixWithNaught(value.toString())));
                    }).toList(),
                    onChanged: !enabled
                        ? null
                        : (int? value) {
                            minuteValue = value;
                            callback("$hourValue:$minuteValue");
                          },
                    validator: validator,
                    value: minuteValue),
              ],
            ))
          ],
        )
      ],
    );
  }
}

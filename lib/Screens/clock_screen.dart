import 'package:alarm_app/Widgets/clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockScreen extends StatelessWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15,
        ),
        const SizedBox(
          height: 50,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ClockWidget(),
            const SizedBox(
              height: 15,
            ),
            Text(
              DateFormat.yMMMd().format(DateTime.now()),
              style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

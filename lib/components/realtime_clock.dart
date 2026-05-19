import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RealtimeClock
    extends StatelessWidget {

  const RealtimeClock({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(

      stream: Stream.periodic(
        const Duration(seconds: 1),
      ),

      builder: (context, snapshot) {

        final now = DateTime.now();

        final formatted =
        DateFormat(
          'd MMMM yyyy HH:mm:ss',
        ).format(now);

        return Text(
          formatted,

          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}
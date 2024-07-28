import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment({
    super.key,
    required this.text,
    required this.time,
    required this.user,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          //comment
          Text(text),

          //user and time
          Row(
            children: [
              Text(user),
              Text("."),
              Text(time),
            ],
          )

          

        ],),
    );
  }
}

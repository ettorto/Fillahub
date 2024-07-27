import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FillaPost extends StatelessWidget {
  final String message;
  final String user;
  

  const FillaPost(
      {super.key,
      required this.message,
      required this.user,
      
      });

  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        ),
      margin: EdgeInsets.only(top:25, left:25, right: 25),
      padding: EdgeInsets.all(25),

      child: Row(
        children: [
          //profile pic
          Container(
            decoration: BoxDecoration(
              shape:BoxShape.circle,
              color: Colors.grey[300]),
            padding:EdgeInsets.all(10),
            child: const Icon(applyTextScaling: Icons.person,
            color)
          ),
          //message and user email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user,
                style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 10
                
                ),
              Text(message),
            ],
          )
        ],
      ),
    );
  }
}
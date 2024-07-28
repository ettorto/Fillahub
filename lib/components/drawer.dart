import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: const Column(
        children: [
          //header
          const DrawerHeader(
            child: Icon(
            Icons.person,
            color: Colors.white,
            size: 64,
            ),
            ),

          //home list title

          //profile list tile

          //logout list tile

        ],)
     

      

    );
  }
}
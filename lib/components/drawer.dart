import 'package:fillahub/components/my_list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  
  final void Function()? onProfileTap;
  final void Function()? onSignout;
  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignout,
    });

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //header
            Column(
              children: [
                const DrawerHeader(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                
                //home list title
                MyListTile(
                  icon: Icons.home,
                  text: 'H O M E',
                  onTap: () => Navigator.pop(context),
                ),
                
                //profile list tile
                Padding(
                  padding: const EdgeInsets.only(bottom:30.0),
                  child: MyListTile(
                    icon: Icons.person, 
                    text: 'P R O F I L E', 
                    onTap: onProfileTap
                    ),
                ),
              ],
            ),

            //logout list tile
            MyListTile(
              icon: Icons.logout,
              text: 'L O G O U T',
              onTap: onSignout,
            ),
          ],
        ),
        );
  }
}

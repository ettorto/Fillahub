import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillahub/components/drawer.dart';
import 'package:fillahub/components/filla_posts.dart';
import 'package:fillahub/components/text_field.dart';
import 'package:fillahub/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();

  // sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    //only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      //store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    //clear the textfield
    setState(() {
      textController.clear();
    });
  }

  //navigate to profile page
  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
            title: const Text("FillaHub"),
            backgroundColor: Colors.grey[900],
           ),
        drawer: MyDrawer(
          onProfileTap: goToProfilePage,
          onSignout: signOut,
        ),
        body: Center(
          child: Column(
            children: [
              //fillahub
              Expanded(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("User Posts")
                          .orderBy(
                            "TimeStamp",
                            descending: false,
                          )
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                //get the message
                                final post = snapshot.data!.docs[index];
                                return FillaPost(
                                  message: post['Message'],
                                  user: post['UserEmail'],
                                  postId: post.id,
                                  likes: List<String>.from(post['Likes'] ?? []),
                                );
                              });
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      })),
              //post a message
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  children: [
                    //textfield
                    Expanded(
                      child: MyTextField(
                        controller: textController,
                        hintText: "Share your filla here",
                        obscureText: false,
                      ),
                    ),
                    //post button
                    IconButton(
                        onPressed: postMessage,
                        icon: const Icon(Icons.arrow_circle_up))
                  ],
                ),
              ),

              //Logged in as
              Text("Logged in as: " + currentUser.email!,
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ));
  }
}

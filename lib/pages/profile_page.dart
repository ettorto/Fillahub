import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillahub/components/text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker _picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 150,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take a Picture'),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context);
                if (image != null) {
                  await _uploadProfileImage(File(image.path));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Select from Gallery'),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context);
                if (image != null) {
                  await _uploadProfileImage(File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfileImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures/${currentUser.email}');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    final imageUrl = await snapshot.ref.getDownloadURL();

    await usersCollection.doc(currentUser.email).update({'profilePicture': imageUrl});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          "Profile Page",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;

                return ListView(
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: Stack(
                        children: [
                          userData['profilePicture'] != null
                              ? CircleAvatar(
                                  radius: 72,
                                  backgroundImage: NetworkImage(userData['profilePicture']),
                                )
                              : const CircleAvatar(
                                  radius: 72,
                                  child: Icon(
                                    Icons.person,
                                    size: 72,
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            left: 110,
                            child: IconButton(
                              icon: const Icon(Icons.add_a_photo),
                              onPressed: _pickProfileImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentUser.email!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        'My Details',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    MyTextBox(
                      text: userData['username'],
                      sectionName: 'username',
                      onPressed: () => editField('username'),
                    ),
                    MyTextBox(
                      text: userData['bio'],
                      sectionName: 'bio',
                      onPressed: () => editField('bio'),
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        'My Posts',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}

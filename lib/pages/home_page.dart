import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillahub/components/drawer.dart';
import 'package:fillahub/components/filla_posts.dart';
import 'package:fillahub/components/text_field.dart';
import 'package:fillahub/helper/helper_methods.dart';
import 'package:fillahub/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.postId});
  
  final String? postId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  XFile? _pickedMedia;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _location; // Store location

  @override
  void initState() {
    super.initState();
    if (widget.postId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToPost(widget.postId!);
      });
    }
  }

  Future<void> _scrollToPost(String postId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('User Posts')
        .doc(postId)
        .get();

    if (snapshot.exists) {
      final index = await _getPostIndex(postId);
      if (index != null) {
        _scrollController.animateTo(
          index * 100.0, // Assuming each post item has a height of 100.0
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<int?> _getPostIndex(String postId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('User Posts')
        .orderBy('TimeStamp', descending: false)
        .get();

    for (int i = 0; i < snapshot.docs.length; i++) {
      if (snapshot.docs[i].id == postId) {
        return i;
      }
    }
    return null;
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _pickMedia() async {
    final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedMedia = media;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _pickedMedia = image;
    });
  }



  // Add the reverse geocoding method
Future<String> _getPlaceName(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      return placemarks.first.name ?? '';
    }
  } catch (e) {
    print('Error getting place name: $e');
  }
  return 'Unknown location';
}



  Future<void> _pickLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    // Get current location
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  String placeName = await _getPlaceName(position.latitude, position.longitude);
  setState(() {
    _location = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'name': placeName,
    };
  });
}

 Future<void> postMessage() async {
  if (!_isUploading &&
      (textController.text.isNotEmpty || _pickedMedia != null)) {
    setState(() {
      _isUploading = true;
    });

    String? mediaUrl;
    if (_pickedMedia != null) {
      mediaUrl = await _uploadMedia();
    }

    try {
      await FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'ImageURL': mediaUrl,
        'Location': _location, // Add location to the post
      });
    } catch (e) {
      print('Error posting message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post message')),
      );
    }

    setState(() {
      textController.clear();
      _pickedMedia = null;
      _location = null; // Clear location
      _isUploading = false;
    });
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Submission Error"),
        content: const Text(
            "Please enter a message or pick an image/video to post."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

  Future<String?> _uploadMedia() async {
    if (_pickedMedia == null) return null;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('post_media/${DateTime.now().toString()}');
    try {
      final uploadTask = storageRef.putFile(File(_pickedMedia!.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final mediaUrl = await snapshot.ref.getDownloadURL();
      return mediaUrl;
    } catch (e) {
      print('Error uploading media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload media')),
      );
      return null;
    }
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 15, 11, 11),
        centerTitle: true,
        title: const Text(
          "FillaHub",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignout: signOut,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return FillaPost(
                        message: post['Message'],
                        user: post['UserEmail'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                        time: formatDate(post['TimeStamp']),
                        imageUrl: post['ImageURL'],
                        location: post['Location'], // Pass location to FillaPost
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                if (_pickedMedia != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: _isUploading
                        ? const CircularProgressIndicator()
                        : Image.file(
                            File(_pickedMedia!.path),
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: textController,
                        hintText: "Share your filla here",
                        obscureText: false,
                      ),
                    ),
                    IconButton(
                      onPressed: _pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                    ),
                    IconButton(
                      onPressed: _pickMedia,
                      icon: const Icon(Icons.image),
                    ),
                    IconButton(
                      onPressed: _pickLocation, // Add button for picking location
                      icon: const Icon(Icons.location_on),
                    ),
                    IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

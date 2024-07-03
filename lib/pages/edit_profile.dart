import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:project_hostelite/widgets/general_widgets.dart';
import 'package:project_hostelite/widgets/signup_login_widgets.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;
  bool _isUploading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;
      _usernameController.text = userData['name'] ?? '';
      _phoneController.text = userData['phone'] ?? '';
      _profileImageUrl = userData['profileImageUrl'] ?? '';
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isUploading = true;
    });

    final String username = _usernameController.text.trim();
    final String phone = _phoneController.text.trim();
    final User? user = FirebaseAuth.instance.currentUser;

    if (username.isEmpty || phone.isEmpty) {
      showSnackBar(context, 'Fields cannot be empty!');
      setState(() {
        _isUploading = false;
      });
      return;
    }
    if (int.tryParse(phone) == null ||
        int.parse(phone) <= 0 ||
        int.parse(phone) > 9999999999) {
      showSnackBar(context, 'Please enter a valid 10-digit phone number');
      setState(() {
        _isUploading = false;
      });
      return;
    }

    String? profileImageUrl = _profileImageUrl;
    if (_profileImage != null) {
      profileImageUrl = await _uploadProfileImage(_profileImage!);
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': username,
        'phone': phone,
        if (profileImageUrl != null)
          'profileImageUrl': profileImageUrl
        else
          'profileImageUrl': null,
      });

      if (!mounted) return;
      showSnackBar(context, 'Profile updated successfully!');
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to update profile!');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String> _uploadProfileImage(File image) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final storageRef = FirebaseStorage.instance.ref().child(
        'profileImages/${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _removeProfileImage() {
    setState(() {
      _profileImage = null;
      _profileImageUrl = null;
    });
  }

  Future<void> _deleteAccount() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Confirm Account Deletion',
              style: TextStyle(fontSize: 18),
            ),
            content:
                const Text('Are you sure you want to delete your account?'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: primaryBlue),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  'Delete',
                  style: TextStyle(color: primaryBlue),
                ),
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        try {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
              ),
            ),
          );
          await user.delete();

          // QuerySnapshot listingSnapshot = await FirebaseFirestore.instance
          //     .collection('listings')
          //     .where('userId', isEqualTo: user.uid)
          //     .get();

          // for (DocumentSnapshot listingDoc in listingSnapshot.docs) {

          //   List<String> storagePaths =
          //       List<String>.from(listingDoc['imageUrls']);
          //   await Future.forEach(storagePaths, (storagePath) async {
          //     await FirebaseStorage.instance.ref().child(storagePath).delete();
          //   await listingDoc.reference.delete();
          //   });
          // }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .delete();

          QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: user.uid)
              .get();

          for (DocumentSnapshot chatDoc in chatSnapshot.docs) {
            await chatDoc.reference.delete();
            if (!mounted) return;
            Navigator.pop(context);

            Navigator.pushReplacementNamed(context, AppRoutes.authRoute);
          }
        } catch (e) {
          if (!mounted) return;
          showSnackBar(context, 'Error deleting account!');
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => !_isUploading,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: scaffoldBackgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                AppBar(
                  title: const Text(
                    'Edit Your Profile',
                  ),
                  backgroundColor: scaffoldBackgroundColor,
                  leading: IconButton(
                    highlightColor: primaryBlue.withOpacity(0.2),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                    ),
                    onPressed: () {
                      if (!_isUploading) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Iconsax.trash,
                        color: Colors.redAccent,
                      ),
                      onPressed: _deleteAccount,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _profileImage != null ||
                                  (_profileImageUrl != null &&
                                      _profileImageUrl!.isNotEmpty)
                              ? _removeProfileImage
                              : _pickProfileImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 50,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (_profileImageUrl != null &&
                                            _profileImageUrl!.isNotEmpty
                                        ? NetworkImage(_profileImageUrl!)
                                        : null) as ImageProvider<Object>?,
                                child: _profileImage == null &&
                                        (_profileImageUrl == null ||
                                            _profileImageUrl!.isEmpty)
                                    ? const Icon(Iconsax.user,
                                        size: 50, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: scaffoldBackgroundColor,
                                      width: 3.0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    _profileImage != null ||
                                            (_profileImageUrl != null &&
                                                _profileImageUrl!.isNotEmpty)
                                        ? Iconsax.close_circle5
                                        : Iconsax.camera5,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        textField(
                          'Full Name',
                          false,
                          Icons.person_2_outlined,
                          _usernameController,
                        ),
                        const SizedBox(height: 20),
                        textField(
                          'Phone',
                          false,
                          Icons.phone_android,
                          _phoneController,
                        ),
                        const SizedBox(height: 35),
                        actionButton('UPDATE', () {
                          _updateUserProfile();
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isUploading)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: primaryBlue),
                      const SizedBox(height: 20),
                      const Text(
                        'Please wait, it might take some time...',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

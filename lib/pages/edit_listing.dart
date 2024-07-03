import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_hostelite/pages/home_page.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/widgets/general_widgets.dart';
import 'package:project_hostelite/widgets/signup_login_widgets.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class EditListingPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String listingId;

  const EditListingPage({super.key, required this.data, required this.listingId});

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _landmarkController;
  final List<String> _imageUrls = [];
  final List<File> _localImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.data['location']);
    _priceController = TextEditingController(text: widget.data['price']);
    _descriptionController =
        TextEditingController(text: widget.data['description']);
    _landmarkController = TextEditingController(text: widget.data['landmark']);
    _imageUrls.addAll((widget.data['imageUrls'] as List)
        .map((url) => url.toString())
        .toList());
  }

  Future<List<String>> _uploadImages() async {
    setState(() {
      _isUploading = true;
    });
    final List<String> downloadUrls = [];
    for (File image in _localImages) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> _updateListing() async {
    final String location = _locationController.text;
    final String price = _priceController.text;
    final String description = _descriptionController.text;
    final String landmark = _landmarkController.text;
    final User? user = FirebaseAuth.instance.currentUser;

    if (location.isEmpty ||
        price.isEmpty ||
        description.isEmpty ||
        landmark.isEmpty) {
      showSnackBar(context, 'Fields cannot be empty!');
      return;
    }
    if (int.tryParse(price) == null ||
        int.parse(price) <= 0 ||
        int.parse(price) > 99999) {
      showSnackBar(context, 'Please enter a valid amount!');
      return;
    }
    if (_imageUrls.isEmpty && _localImages.isEmpty) {
      showSnackBar(context, 'Image is required!');
      return;
    }
    try {
      final newImageUrls = await _uploadImages();
      final allImageUrls = [..._imageUrls, ...newImageUrls];

      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .update({
        'location': location,
        'price': price,
        'description': description,
        'landmark': landmark,
        'imageUrls': allImageUrls,
        'userId': user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Property successfully updated on Hostelite',
        title: 'SUCCESS!',
        confirmBtnText: 'OK',
        onConfirmBtnTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
          );
        },
      );

      _locationController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _landmarkController.clear();
    } catch (e) {
      showSnackBar(context, 'Error updating details: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _localImages.addAll(pickedFiles.map((file) => File(file.path)).toList());
    });
  }

  void _removeImage(int index, bool isUrl) {
    setState(() {
      if (isUrl) {
        _imageUrls.removeAt(index);
      } else {
        _localImages.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                title: const Text('Edit Your Property'),
                backgroundColor: scaffoldBackgroundColor,
                leading: IconButton(
                  highlightColor: primaryBlue.withOpacity(0.2),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Update Room Details',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 25),
                        textField('Location', false, Icons.location_on_rounded,
                            _locationController),
                        const SizedBox(height: 20),
                        textField('Rent Per Month', false, Icons.money,
                            _priceController),
                        const SizedBox(height: 20),
                        textField('Landmark (e.g, Near Islamia College)', false,
                            Icons.map_rounded, _landmarkController),
                        const SizedBox(height: 20),
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.5),
                                offset: const Offset(0, 5),
                                spreadRadius: -15,
                                blurRadius: 20,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            maxLines: 100,
                            controller: _descriptionController,
                            style: TextStyle(color: primaryBlue),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 10, bottom: 95),
                                child: Icon(
                                  Iconsax.home5,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    BorderSide(color: primaryBlue, width: 1.6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintText: 'Description',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            cursorColor: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose Images',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              _imageUrls.length + _localImages.length + 1,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                          ),
                          itemBuilder: (context, index) {
                            if (index ==
                                _imageUrls.length + _localImages.length) {
                              return GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              );
                            } else if (index < _imageUrls.length) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(_imageUrls[index]),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Positioned(
                                    top: 7,
                                    right: 7,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index, true),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(_localImages[
                                            index - _imageUrls.length]),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Positioned(
                                    top: 7,
                                    right: 7,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(
                                          index - _imageUrls.length, false),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 35),
                        actionButton('UPDATE', () {
                          _updateListing();
                        }),
                      ],
                    ),
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
                      'Please wait, it might take a while...',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

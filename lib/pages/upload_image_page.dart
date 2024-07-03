import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
    });
    }

  Future<void> _uploadImages() async {
    setState(() {
      _isUploading = true;
    });

    // final List<String> downloadUrls = [];
    // for (File image in _images) {
    //   final storageRef = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');
    //   final uploadTask = storageRef.putFile(image);
    //   final snapshot = await uploadTask.whenComplete(() => null);
    //   final downloadUrl = await snapshot.ref.getDownloadURL();
    //   downloadUrls.add(downloadUrl);
    // }

    // await FirebaseFirestore.instance.collection('images').add({
    //   'urls': downloadUrls,
    // });

    setState(() {
      _isUploading = false;
      _images.clear();
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Images'),
          actions: [
            _images.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.upload),
                    onPressed: _isUploading ? null : _uploadImages,
                  )
                : Container(),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: _images.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: _pickImages,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.grey,
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(_images[index - 1]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _removeImage(index - 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            if (_isUploading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

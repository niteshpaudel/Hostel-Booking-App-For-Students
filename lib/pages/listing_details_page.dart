import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_hostelite/screens/chat_screen.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/widgets/general_widgets.dart';
import 'package:project_hostelite/widgets/property_details.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailsPage extends StatefulWidget {
  final DocumentSnapshot listing;
  final Map<String, dynamic> userData;

  const ListingDetailsPage({
    super.key,
    required this.listing,
    required this.userData,
  });

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  int _selectedImageIndex = 0;
  PageController? _controller;
  bool _isDescriptionExpanded = false;
  bool _isDescriptionOverflowing = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.listing.data() as Map<String, dynamic>;
    final images = List<String>.from(data['imageUrls']);
    final description = data['description'].trim();

    Future<void> startChat(BuildContext context) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      final otherUserId = data['userId'];
      if (currentUser!.uid == otherUserId) {
        showSnackBar(context, 'You cannot chat with yourself!');
        return;
      }
      final chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .get();

      DocumentSnapshot? existingChat;

      for (var chat in chatQuery.docs) {
        final participants = List<String>.from(chat['participants']);
        if (participants.contains(otherUserId)) {
          existingChat = chat;
          break;
        }
      }

      if (existingChat != null) {
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: existingChat!.id,
              otherUser: widget.userData,
            ),
          ),
        );
      } else {
        final chatRef = FirebaseFirestore.instance.collection('chats').doc();

        await chatRef.set({
          'participants': [currentUser.uid, otherUserId],
          'lastMessage': '',
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatRef.id,
              otherUser: widget.userData,
            ),
          ),
        );
      }
    }

    Future<void> reportListing() async {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('reported').add({
          'listingId': widget.listing.id,
          'reportedBy': currentUser.uid,
          'listingOwnerId': data['userId'],
          'timestamp': FieldValue.serverTimestamp(),
        });
        if (!context.mounted) return;
        showSnackBar(context, 'Listing reported successfully!');
      } else {
        showSnackBar(context, 'You need to be logged in to report a listing.');
      }
    }

    void showReportDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Confirm Report',
              style: TextStyle(fontSize: 18),
            ),
            content:
                const Text('Are you sure you want to report this listing?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: primaryBlue),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  reportListing();
                },
                child: Text(
                  'Report',
                  style: TextStyle(color: primaryBlue),
                ),
              ),
            ],
          );
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final span =
          TextSpan(text: description, style: const TextStyle(fontSize: 16));
      final tp = TextPainter(
          maxLines: 3,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          text: span);
      tp.layout(maxWidth: size.width);
      if (tp.didExceedMaxLines && !_isDescriptionOverflowing) {
        setState(() {
          _isDescriptionOverflowing = true;
        });
      }
    });

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        title: const Text('Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: showReportDialog,
            icon: const Icon(Iconsax.flag, color: Colors.red),
            tooltip: 'Report Listing',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0), // Add gap between images
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Gallery',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(images.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller!.animateToPage(index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut);
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: _selectedImageIndex == index
                                      ? Colors.blue
                                      : Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  images[index],
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              data['location'].trim(),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.clip),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Icon(
                  Iconsax.location5,
                  color: primaryBlue.withOpacity(0.8),
                  size: 18,
                ),
                Expanded(
                  child: Text(
                    data['landmark'].trim(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: primaryBlue.withOpacity(0.8),
                        overflow: TextOverflow.clip,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              children: [
                Icon(
                  Iconsax.clock5,
                  size: 17,
                  color: primaryBlue.withOpacity(0.8),
                ),
                Text(
                  " ${formatTimestamp(data['timestamp'])}",
                  style: TextStyle(
                      color: primaryBlue.withOpacity(0.8), fontSize: 15),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Container(
              decoration: BoxDecoration(
                  color: primaryBlue, borderRadius: BorderRadius.circular(4)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.currency_rupee_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    Text(
                      data['price'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Row(
                  children: [
                    widget.userData['profileImageUrl'] == null
                        ? Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              image: const DecorationImage(
                                  image: AssetImage('assets/icons/user.png'),
                                  fit: BoxFit.cover),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                image: NetworkImage(
                                    widget.userData['profileImageUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.userData['name'],
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        'Owner',
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final phone = widget.userData['phone'];
                        if (phone != null) {
                          final url = Uri(scheme: 'tel', path: phone);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        }
                      },
                      padding: const EdgeInsets.all(12),
                      highlightColor: primaryBlue,
                      icon: const Icon(
                        Iconsax.call5,
                        size: 22,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(backgroundColor: primaryBlue),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () => startChat(context),
                      padding: const EdgeInsets.all(12),
                      style: IconButton.styleFrom(backgroundColor: primaryBlue),
                      icon: const Icon(
                        Iconsax.message5,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            Text(
              description,
              maxLines: _isDescriptionExpanded ? null : 3,
              overflow: _isDescriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            if (_isDescriptionOverflowing)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: Text(
                  _isDescriptionExpanded ? 'Show Less' : 'Show More',
                  style: TextStyle(
                    fontSize: 15,
                    color: primaryBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

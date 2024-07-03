import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_hostelite/pages/listing_details_page.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:project_hostelite/widgets/general_widgets.dart';
import 'package:project_hostelite/widgets/property_details.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Listings',
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBackgroundColor,
        leading: IconButton(
          highlightColor: primaryBlue.withOpacity(0.2),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 22,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.homeRoute);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListingsList(userId: currentUser?.uid),
      ),
    );
  }
}

class ListingsList extends StatelessWidget {
  final String? userId;

  const ListingsList({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching listings.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No listings found.'));
        }

        final listings = snapshot.data!.docs;

        return ListView.builder(
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            final data = listing.data() as Map<String, dynamic>;

            if (data.isEmpty) {
              return const ListTile(
                title: Text('No data available'),
              );
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                return GestureDetector(
                  child: propertyDetailsCard(data, userId!, listing.id,
                      (listingId) {
                    _deleteListing(context, listingId);
                  }, context),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListingDetailsPage(
                          listing: listing,
                          userData: userData,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _deleteListing(BuildContext context, String listingId) {
    FirebaseFirestore.instance
        .collection('listings')
        .doc(listingId)
        .delete()
        .then((_) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "SUCCESS",
        text: 'Listing deleted successfully!',
        showConfirmBtn: false,
      );
    }).catchError((error) {
      showSnackBar(context, 'Failed to delete listing!');
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:project_hostelite/widgets/property_details.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'listing_details_page.dart';

class AllListingsPage extends StatelessWidget {
  const AllListingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Explore',
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
      body: const Padding(
        padding: EdgeInsets.all(14.0),
        child: ListingsList(),
      ),
    );
  }
}

class ListingsList extends StatelessWidget {
  const ListingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryBlue,
            ),
          );
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
                  return const ListTile();
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                return GestureDetector(
                  child: propertyDetailsCard(data, userId, listing.id,
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
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete listing: $error')),
      );
    });
  }
}

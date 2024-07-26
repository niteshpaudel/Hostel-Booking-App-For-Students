import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'listing_details_page.dart';

class ReportedListings extends StatefulWidget {
  const ReportedListings({super.key});

  @override
  State<ReportedListings> createState() => _ReportedListingsState();
}

class _ReportedListingsState extends State<ReportedListings> {
  Future<List<Map<String, dynamic>>> _fetchReportedListings() async {
    final reportedDocs =
        await FirebaseFirestore.instance.collection('reported').get();

    final reportedListings = <Map<String, dynamic>>[];

    for (var doc in reportedDocs.docs) {
      final listingDoc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(doc['listingId'])
          .get();

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(doc['listingOwnerId'])
          .get();

      reportedListings.add({
        'reportedDoc': doc,
        'listingDoc': listingDoc,
        'userDoc': userDoc,
      });
    }

    return reportedListings;
  }

  Future<void> _deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    setState(() {});
  }

  Future<void> _deleteListing(String listingId) async {
    await FirebaseFirestore.instance
        .collection('listings')
        .doc(listingId)
        .delete();
    setState(() {});
  }

  Future<void> _markListingAsSafe(String reportId, String listingId) async {
    await FirebaseFirestore.instance
        .collection('reported')
        .doc(reportId)
        .delete();
    setState(() {});
  }

  Future<void> _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: primaryBlue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm', style: TextStyle(color: primaryBlue)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reported Listings'),
        centerTitle: true,
        backgroundColor: scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.userProfileRoute);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchReportedListings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: primaryBlue,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No reported listings found.'));
            }

            final reportedListings = snapshot.data!;

            return ListView.builder(
              itemCount: reportedListings.length,
              itemBuilder: (context, index) {
                final listingDoc =
                    reportedListings[index]['listingDoc'] as DocumentSnapshot;
                final userDoc =
                    reportedListings[index]['userDoc'] as DocumentSnapshot;
                final reportDoc =
                    reportedListings[index]['reportedDoc'] as DocumentSnapshot;

                final listingData = listingDoc.data() as Map<String, dynamic>;
                final userData = userDoc.data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListingDetailsPage(
                          listing: listingDoc,
                          userData: userData,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: primaryBlue.withOpacity(0.5),
                              offset: const Offset(0, 5),
                              spreadRadius: -15,
                              blurRadius: 20),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 135,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(listingData['imageUrls'][0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          listingData['location'],
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          child: const Icon(
                                            Iconsax.trash,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          onTap: () {
                                            _showConfirmDialog(
                                              title: 'Delete Listing',
                                              content:
                                                  'Are you sure you want to delete this listing?',
                                              onConfirm: () {
                                                _deleteListing(listingDoc.id);
                                              },
                                            );
                                          },
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          child: const Icon(
                                            Iconsax.profile_delete,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          onTap: () {
                                            _showConfirmDialog(
                                              title: 'Delete User',
                                              content:
                                                  'Are you sure you want to delete this user?',
                                              onConfirm: () {
                                                _deleteUser(userDoc.id);
                                              },
                                            );
                                          },
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          child: const Icon(
                                            Iconsax.flag,
                                            color: Colors.green,
                                            size: 22,
                                          ),
                                          onTap: () {
                                            _showConfirmDialog(
                                              title: 'Mark as Safe',
                                              content:
                                                  'Are you sure you want to mark this listing as safe?',
                                              onConfirm: () {
                                                _markListingAsSafe(
                                                  reportDoc.id,
                                                  listingDoc.id,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

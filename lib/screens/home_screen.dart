import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_hostelite/pages/listing_details_page.dart';
import 'package:project_hostelite/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  List<DocumentSnapshot> searchResults = [];
  bool isSearching = false;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void searchListings(String query) async {
    setState(() {
      isSearching = true;
    });

    final QuerySnapshot allListings =
        await FirebaseFirestore.instance.collection('listings').get();

    final filteredListings = allListings.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final landmark = data['landmarklc'] as String;
      final location = data['locationlc'] as String;
      return landmark.contains(query.toLowerCase()) ||
          location.contains(query.toLowerCase());
    }).toList();

    setState(() {
      searchResults = filteredListings;
      isSearching = false;
    });
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Discover\nYour New Home!',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                focusNode: _focusNode,
                style: TextStyle(color: primaryBlue),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(24, 16, 14, 16),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: Icon(
                      Iconsax.search_normal,
                      color: _isFocused ? primaryBlue : Colors.grey.shade400,
                    ),
                  ),
                  hintText: 'Search by landmark or location...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: primaryBlue, width: 1.6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                cursorColor: primaryBlue,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  searchListings(value);
                },
              ),
              if (isSearching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: CircularProgressIndicator(color: primaryBlue),
                )
              else if (searchQuery.isNotEmpty && searchResults.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final doc = searchResults[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(data['userId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile();
                          }

                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.5),
                                  offset: const Offset(0, 5),
                                  spreadRadius: -15,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(data['imageUrls'][0]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                data['location'],
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 17,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['landmark'],
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '₹${data['price']}',
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ListingDetailsPage(
                                      listing: doc,
                                      userData: userData,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              else if (searchQuery.isEmpty)
                const FeaturedListings(),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturedListings extends StatelessWidget {
  const FeaturedListings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 30,
        ),
        Container(
          height: 130,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'FIND THE BEST ROOM\nIN YOUR BUDGET!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/images/house2.png',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const SectionTitle(title: "Featured Listings"),
        const SizedBox(
          height: 250,
          child: ListingsListView(),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class ListingsListView extends StatelessWidget {
  const ListingsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('availability', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.transparent));
        }

        final listings = snapshot.data!.docs;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            final data = listing.data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.transparent),
                  );
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                  child: GestureDetector(
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
                    child: Stack(
                      children: [
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.5),
                                offset: const Offset(0, 5),
                                spreadRadius: -15,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(data['imageUrls'][0]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 10, 8, 2),
                                child: Text(
                                  data['location'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  data['landmark'],
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: primaryBlue,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 2, 7, 2),
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
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

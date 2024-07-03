import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_hostelite/pages/edit_listing.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

String formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) {
    return 'Unknown time';
  }
  final DateTime dateTime = timestamp.toDate();
  return timeago.format(dateTime);
}

Padding propertyDetailsCard(Map<String, dynamic> data, String currentUserId,
    String listingId, Function onDelete, BuildContext context) {
  return Padding(
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
                  image: NetworkImage(data['imageUrls'][0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      data['location'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis),
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
                            " ${data['landmark']}",
                            style: TextStyle(
                                color: primaryBlue.withOpacity(0.8),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
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
                          style: TextStyle(color: primaryBlue.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(4)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 2, 6, 2),
                            child: Row(
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
                        const Spacer(),
                        if (data['userId'] == currentUserId)
                          Row(
                            children: [
                              GestureDetector(
                                child: Icon(
                                  Iconsax.edit,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditListingPage(
                                          data: data, listingId: listingId),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              GestureDetector(
                                child: const Icon(Iconsax.trash,
                                    size: 20, color: Colors.redAccent),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        titleTextStyle: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                        content: const Text(
                                            'Are you sure you want to delete this listing?'),
                                        actions: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                                foregroundColor: primaryBlue),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                                foregroundColor: primaryBlue),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              onDelete(listingId);
                                            },
                                            child: const Text('Confirm'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

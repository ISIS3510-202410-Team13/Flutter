import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_drive/reviews.dart';

class SingleReview extends StatelessWidget {
  final List<Review> reviews;

  SingleReview({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
            return Card(
            color: Color(0xFFFFebc6),
            child: ListTile(
              leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/user${Random().nextInt(4) + 1}.png'),
              ),
              title: Text(reviews[index].user),
              subtitle: Text(reviews[index].text),
            ),
            );
        },
      ),
    );
  }
}
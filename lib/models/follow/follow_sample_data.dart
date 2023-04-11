import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reel_t/models/follow/follow.dart';

class FollowData {
  Future<void> initFollowData() async {
    final db = FirebaseFirestore.instance.collection(Follow.PATH);
    for (int i = 0; i < 10; i++) {
      var follow = Follow(
          id: i.toString(),
          userId: i.toString(),
          followerId: 'Pg8GacuZI2aqJRXLBDmXXZqGVwo1',
          isFollow: true);
     await db.doc(i.toString()).set(follow.toJson());
    }
  }
}

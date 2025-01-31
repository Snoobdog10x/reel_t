import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reel_t/models/conversation/conversation.dart';
import 'package:reel_t/models/message/message.dart';

import '../../../shared_product/utils/format/format_utlity.dart';

abstract class SendMessageEvent {
  final _db = FirebaseFirestore.instance.collection(Conversation.PATH);
  Future<void> sendSendMessageEvent(
      Conversation conversation, Message message) async {
    try {
      var conversationRef = _db.doc(conversation.id);
      var messageRef = conversationRef.collection(Message.PATH).doc();
      var id = messageRef.id;
      final batch = FirebaseFirestore.instance.batch();
      conversation.updateAt = FormatUtility.getMillisecondsSinceEpoch();
      conversation.latestMessage = message.toStringJson();
      batch.set(conversationRef, conversation.toJson());
      message.id = id;
      batch.set(messageRef, message.toJson());
      await batch.commit();
      onSendMessageEventDone(null);
    } catch (e) {
      print("SendMessageEvent $e");
      onSendMessageEventDone(e);
    }
  }

  void disposeSendMessageEvent() {}

  void onSendMessageEventDone(dynamic e);
}

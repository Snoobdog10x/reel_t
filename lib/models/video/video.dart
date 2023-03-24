import 'dart:convert';

import 'package:reel_t/models/like/like.dart';
import 'package:video_player/video_player.dart';

enum PublicMode { PUBLIC, PRIVATE }

class Video {
  late String id;
  late String videoUrl;
  late String songName;
  late String creatorId;
  late int publicMode;
  late int comments;
  late int likesNum;
  late int viewsNum;
  late bool isDeleted;
  List<Like> likes = [];
  Function? _notifyDataChanged;
  VideoPlayerController? _controller;
  Video({
    String? id,
    String? videoUrl,
    String? songName,
    String? creatorId,
    int? publicMode,
    int? comments,
    int? likesNum,
    int? viewsNum,
    bool? isDeleted,
  }) {
    this.id = id ?? "";
    this.videoUrl = videoUrl ?? "";
    this.songName = songName ?? "";
    this.creatorId = creatorId ?? "";
    this.publicMode = publicMode ?? 0;
    this.comments = comments ?? 0;
    this.likesNum = likesNum ?? 0;
    this.viewsNum = viewsNum ?? 0;
    this.isDeleted = isDeleted ?? false;
  }
  void initController(Function notifyDataChanged) async {
    if (_controller != null && _controller!.value.isInitialized) {
      return;
    }
    this._notifyDataChanged = notifyDataChanged;
    _controller = VideoPlayerController.network(videoUrl);
    _controller!.addListener(() {
      notifyDataChanged();
    });
    _controller!.setLooping(true);
    await _controller!.initialize();
    _controller!.play();
  }

  void disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  bool isInitialized() {
    if (_controller != null && _controller!.value.isInitialized) {
      return true;
    }
    return false;
  }

  void playVideo() {
    _controller?.play();
  }

  void stopVideo() {
    _controller?.pause();
  }

  VideoPlayerController? getVideoController() {
    return _controller;
  }

  Video.fromJson(Map<dynamic, dynamic> json) {
    id = json["id"];
    videoUrl = json["videoUrl"];
    songName = json["songName"];
    creatorId = json["creatorId"];
    publicMode = json["publicMode"];
    comments = json["comments"];
    likesNum = json["likesNum"];
    viewsNum = json["viewsNum"];
    isDeleted = json["isDeleted"];
  }

  Video.fromStringJson(String stringJson) {
    Map valueMap = json.decode(stringJson);
    Video.fromJson(valueMap);
  }

  String toStringJson() {
    return json.encode(this.toJson());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["videoUrl"] = this.videoUrl;
    data["songName"] = this.songName;
    data["creatorId"] = this.creatorId;
    data["publicMode"] = this.publicMode;
    data["comments"] = this.comments;
    data["likesNum"] = this.likesNum;
    data["viewsNum"] = this.viewsNum;
    data["isDeleted"] = this.isDeleted;
    return data;
  }
}

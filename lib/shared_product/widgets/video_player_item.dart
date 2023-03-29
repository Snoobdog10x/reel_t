import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/video/video.dart';

class VideoPlayerItem extends StatefulWidget {
  final Video video;
  final bool isPlay;
  const VideoPlayerItem({
    super.key,
    required this.video,
    this.isPlay = false,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  @override
  void initState() {
    super.initState();
    widget.video.initController(widget.isPlay, notifyDataChanged);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.video.isInitialized()) {
      return buildLoadWidget();
    }
    return buildReadyVideo();
  }

  void notifyDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildReadyVideo() {
    var _controller = widget.video.getVideoController()!;
    return GestureDetector(
      onTap: () {
        widget.video.changeVideoState();
      },
      child: VisibilityDetector(
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction <= 0.7) {
            widget.video.stopVideo();
            return;
          }
          widget.video.playVideo();
        },
        key: ObjectKey(this),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.aspectRatio,
              height: 1,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoadWidget() {
    return Container(
      color: Colors.black,
      child: CupertinoActivityIndicator(
        radius: 20,
        color: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    widget.video.disposeController();
    super.dispose();
  }
}

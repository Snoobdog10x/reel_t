import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reel_t/screens/video/list_video/list_video_screen.dart';
import 'package:reel_t/shared_product/widgets/image/circle_image.dart';
import '../../../generated/abstract_bloc.dart';
import '../../../generated/abstract_state.dart';
import '../../../models/follow/follow.dart';
import '../../../models/user_profile/user_profile.dart';
import '../../../models/video/video.dart';
import '../../../shared_product/assets/icon/tik_tok_icons_icons.dart';
import '../../../shared_product/utils/format/format_utlity.dart';
import '../../../shared_product/utils/text/shared_text_style.dart';
import '../../../shared_product/widgets/button/three_row_button.dart';
import '../../reuseable/commingsoon/commingsoon_screen.dart';
import '../../sub_setting_user/setting_and_privacy_personal/setting_and_privacy_personal_screen.dart';
import '../login/login_screen.dart';
import '../switch_account/switch_account_screen.dart';
import 'edit_profile/edit_profile_screen.dart';
import 'profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile user;
  final bool isBack;
  final Follow? userFollow;
  final Function(String userId, Follow? userFollow)? callBackFollow;
  const ProfileScreen({
    super.key,
    required this.user,
    this.isBack = false,
    this.userFollow,
    this.callBackFollow,
  });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends AbstractState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  late ProfileBloc bloc;
  bool isCurrentUserProfile = false;
  var controller = ScrollController();

  @override
  AbstractBloc initBloc() {
    return bloc;
  }

  @override
  BuildContext initContext() {
    return context;
  }

  @override
  void onCreate() {
    bloc = ProfileBloc();
    bloc.init(widget.userFollow);
    controller.addListener(() {
      if (controller.position.atEdge) {
        bool isTop = controller.position.pixels == 0;
        if (isTop) {
          if (bloc.userVideos.toList().length < 9) {
            bloc.sendRetrieveUserVideoEvent(widget.user.id);
          }
          return;
        }

        bloc.sendRetrieveUserVideoEvent(widget.user.id);
      }
    });
    if (widget.user.id.isNotEmpty)
      bloc.sendStreamingUserProfileEvent(widget.user.id);
  }

  @override
  void onReady() {
    bloc.sendRetrieveUserVideoEvent(widget.user.id);
    if (appStore.localUser.isLogin()) {
      if (widget.user.id != appStore.localUser.getCurrentUser().id)
        bloc.sendGetFollowUserEvent(
            appStore.localUser.getCurrentUser().id, widget.user.id);
    }
    isCurrentUserProfile = widget.user == bloc.currentUser;

    if (widget.user.id.isNotEmpty)
      bloc.sendStreamingUserProfileEvent(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => bloc,
      builder: (context, child) {
        return Consumer<ProfileBloc>(
          builder: (context, value, child) {
            var appBar = buildAppbar();
            var body = buildBody();
            return buildScreen(
              appBar: appBar,
              body: body,
              notLoggedBody: isCurrentUserProfile ? buildLoggedBody() : body,
              padding: EdgeInsets.symmetric(horizontal: 8),
              isSafeBottom: false,
            );
          },
        );
      },
    );
  }

  Widget buildLoggedBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          TikTokIcons.profile,
          size: 150,
          color: Colors.grey[300],
        ),
        SizedBox(height: 8),
        Text(
          "Your profile will be shown here",
          style: TextStyle(
            fontSize: SharedTextStyle.SUB_TITLE_SIZE,
            fontWeight: SharedTextStyle.SUB_TITLE_WEIGHT,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: screenWidth() * 0.6,
          child: ThreeRowButton(
            onTap: () {
              pushToScreen(LoginScreen());
            },
            title: Text(
              "Login",
              style: TextStyle(
                fontSize: SharedTextStyle.SUB_TITLE_SIZE,
                fontWeight: SharedTextStyle.SUB_TITLE_WEIGHT,
                color: Colors.white,
              ),
            ),
            color: Colors.red,
          ),
        )
      ],
    );
  }

  Widget buildAppbar() {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  if (widget.isBack) {
                    popTopDisplay();
                    return;
                  }
                  pushToScreen(CommingsoonScreen());
                },
                child: Container(
                  height: 30,
                  width: 30,
                  child: Icon(
                    widget.isBack
                        ? Icons.arrow_back_ios_new_outlined
                        : CupertinoIcons.gift_fill,
                    color: widget.isBack ? Colors.black : Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                if (!isCurrentUserProfile) return;
                if (appStore.localUser.isLogin())
                  showScreenBottomSheet(SwitchAccountScreen());
              },
              child: Center(
                child: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.user.fullName,
                        style: TextStyle(
                          fontSize: SharedTextStyle.SUB_TITLE_SIZE,
                          fontWeight: SharedTextStyle.SUB_TITLE_WEIGHT,
                        ),
                      ),
                      if (isCurrentUserProfile)
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 12,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          isCurrentUserProfile
              ? Expanded(
                  flex: 2,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            pushToScreen(CommingsoonScreen());
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            child: Icon(
                              CupertinoIcons.paw,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            if (!isCurrentUserProfile) return;
                            if (appStore.localUser.isLogin())
                              pushToScreen(SettingAndPrivacyPersonalScreen());
                          },
                          child: isCurrentUserProfile
                              ? Container(
                                  height: 30,
                                  width: 30,
                                  child: Icon(
                                    CupertinoIcons.line_horizontal_3,
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                    ],
                  ),
                )
              : Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      pushToScreen(CommingsoonScreen());
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      child: Icon(
                        CupertinoIcons.paw,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: <Widget>[
          buildAvatar(),
          SizedBox(height: 16),
          buildStatistic(),
          SizedBox(height: 8),
          buildButtonMore(),
          SizedBox(height: 8),
          buildBio(),
          SizedBox(height: 8),
          if (bloc.userVideos.toList().isNotEmpty) ...[
            Divider(
              color: Color.fromARGB(255, 200, 200, 200),
              height: 0,
              thickness: 1,
            )
          ],
          SizedBox(height: 8),
          buildShowVideo(),
          if (bloc.userVideos.length() >= 9) buildLoadMore(),
        ],
      ),
    );
  }

  Widget buildLoadMore() {
    return Container(
      height: 50,
      width: screenWidth(),
      alignment: Alignment.center,
      child: CupertinoActivityIndicator(
        radius: 15,
        color: Colors.white,
      ),
    );
  }

  Widget buildAvatar() {
    return Column(
      children: <Widget>[
        CircleImage(
          widget.user.avatar,
          radius: 100,
        ),
        SizedBox(height: 8),
        Text(
          widget.user.userName,
          style: TextStyle(fontWeight: SharedTextStyle.NORMAL_WEIGHT),
        ),
      ],
    );
  }

  Widget buildStatistic() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildStatisticItems(widget.user.numFollowing, 'Following'),
        SizedBox(width: 14),
        Container(
          color: Color.fromARGB(255, 200, 200, 200),
          height: 30,
          width: 1,
        ),
        SizedBox(width: 14),
        buildStatisticItems(widget.user.numFollower, 'Follower'),
        SizedBox(width: 14),
        Container(
          color: Color.fromARGB(255, 200, 200, 200),
          height: 30,
          width: 1,
        ),
        SizedBox(width: 14),
        buildStatisticItems(widget.user.numLikes, 'Likes'),
      ],
    );
  }

  Widget buildStatisticItems(int value, String title) {
    return Column(
      children: [
        Text(
          FormatUtility.formatNumber(value),
          style: TextStyle(
            fontSize: 17,
            fontWeight: SharedTextStyle.SUB_TITLE_WEIGHT,
          ),
        ),
        SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget buildButtonMore() {
    if (appStore.localUser.getCurrentUser() == widget.user)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                pushToScreen(EditProfileScreen());
              },
              child: Text(
                'Edit Profile',
                style: TextStyle(
                    fontSize: SharedTextStyle.NORMAL_SIZE,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 210, 210, 210),
                  elevation: 0),
            ),
          ),
          SizedBox(width: 6),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 210, 210, 210),
                  elevation: 0),
              child: Text(
                'Add friends',
                style: TextStyle(
                    fontSize: SharedTextStyle.NORMAL_SIZE,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          width: 100,
          child: GestureDetector(
            onTap: () {
              bloc.sendUserFollow(widget.user.id);
            },
            child: bloc.isFollowUser()
                ? Container(
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: Text(
                      'Unfollow',
                      style: TextStyle(
                          fontSize: SharedTextStyle.NORMAL_SIZE,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    color: Colors.red,
                    child: Text(
                      'Follow',
                      style: TextStyle(
                          fontSize: SharedTextStyle.NORMAL_SIZE,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget buildBio() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        widget.user.bio,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: SharedTextStyle.NORMAL_SIZE,
          fontWeight: SharedTextStyle.NORMAL_WEIGHT,
        ),
      ),
    );
  }

  Widget buildShowOption() {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(
                CupertinoIcons.circle_grid_hex,
                size: 20,
              ),
            ),
            Expanded(
              flex: 2,
              child: Icon(
                CupertinoIcons.lock_shield,
                size: 20,
              ),
            ),
            Expanded(
              flex: 2,
              child: Icon(
                CupertinoIcons.tag,
                size: 20,
              ),
            ),
            Expanded(
              flex: 2,
              child: Icon(
                CupertinoIcons.circle_grid_hex,
                size: 20,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Container(
            color: Color.fromARGB(255, 200, 200, 200),
            height: 2,
            width: screenWidth()),
      ],
    );
  }

  Widget buildShowVideo() {
    var videos = bloc.userVideos;
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: screenHeight() * 0.2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: videos.toList().length,
      itemBuilder: (context, index) {
        return buildUserVideoThumbnail(videos.toList()[index]);
      },
    );
  }

  Widget buildUserVideoThumbnail(Video video) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        VideoThumbnailDisplay(thumbnail: video.videoThumbnail),
        buildVideoMask(bloc.userVideos.toList().indexOf(video)),
      ],
    );
  }

  Widget buildVideoMask(int index) {
    return GestureDetector(
      onTap: () {
        pushToScreen(
          ListVideoScreen(
            videos: bloc.userVideos.toList(),
            loadMoreVideos: () {},
            startAtIndex: index,
            isShowBack: true,
          ),
        );
      },
      child: Container(
        color: Colors.grey.withOpacity(0.6),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // bool checkFollower(){
  //   if()
  // }
  @override
  void onPopWidget(String previousScreen) {
    // TODO: implement onPopWidget
    super.onPopWidget(previousScreen);
    if (appStore.localUser.isLogin()) {
      if (widget.user.id != appStore.localUser.getCurrentUser().id)
        bloc.sendGetFollowUserEvent(
            appStore.localUser.getCurrentUser().id, widget.user.id);
    }
  }

  @override
  void onDispose() {}

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class VideoThumbnailDisplay extends StatefulWidget {
  final String thumbnail;
  const VideoThumbnailDisplay({super.key, this.thumbnail = ''});

  @override
  State<VideoThumbnailDisplay> createState() => _VideoThumbnailDisplayState();
}

class _VideoThumbnailDisplayState extends State<VideoThumbnailDisplay>
    with AutomaticKeepAliveClientMixin {
  late Uint8List decodedImage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    decodedImage = Base64Decoder().convert(widget.thumbnail);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.thumbnail.isEmpty) return Container(color: Colors.black);
    return Container(
      child: Image.memory(decodedImage, fit: BoxFit.cover),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/video/video.dart';
import '../../../generated/abstract_provider.dart';
import '../../../generated/abstract_state.dart';
import 'feed_provider.dart';
import '../list_video/list_video_screen.dart';

class FeedScreen extends StatefulWidget {
  
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends AbstractState<FeedScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late FeedProvider provider;
  late TabController tabController;
  @override
  AbstractProvider initProvider() {
    return provider;
  }

  @override
  BuildContext initContext() {
    return context;
  }

  @override
  void onCreate() {
    provider = FeedProvider();
    tabController = TabController(length: 2, vsync: this);
    if (appStore.isConnected()) {
      provider.sendRetrieveVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider(
      create: (context) => provider,
      builder: (context, child) {
        return Consumer<FeedProvider>(
          builder: (context, value, child) {
            var body = buildBody();
            return buildScreen(
              body: body,
              isSafe: false,
              background: Colors.black,
            );
          },
        );
      },
    );
  }

  Widget buildAppBar() {
    return Container(
      margin: EdgeInsets.only(top: paddingTop()),
      height: 50,
      width: screenWidth(),
      decoration: BoxDecoration(),
      child: Column(
        children: [
          Expanded(flex: 2, child: Container()),
          Expanded(
            flex: 6,
            child: TabBar(
              controller: tabController,
              isScrollable: true, // here
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(13),
              ),
              labelColor: Colors.white,
              labelStyle: TextStyle(
                fontFamily: "SF Pro Text",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              unselectedLabelColor: Colors.white,
              unselectedLabelStyle: TextStyle(
                fontFamily: "SF Pro Text",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              tabs: <Widget>[
                Tab(
                  child: Text(
                    "For you",
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  child: Text(
                    "Following",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Container()),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Stack(
      children: [
        TabBarView(
          controller: tabController,
          children: [
            ListVideoScreen(
              videos: provider.forYou,
              loadMoreVideos: () {
                provider.sendRetrieveVideos();
              },
            ),
            ListVideoScreen(
              videos: provider.following,
              loadMoreVideos: () {},
            ),
          ],
        ),
        buildAppBar(),
      ],
    );
  }

  @override
  void onDispose() {
    
  }

  @override
  void onReady() {
    // TODO: implement onReady
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

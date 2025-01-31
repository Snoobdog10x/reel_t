import 'package:firebase_auth_platform_interface/src/providers/oauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reel_t/events/setting/create_user_setting/create_user_setting_event.dart';
import 'package:reel_t/events/setting/retrieve_user_setting/retrieve_user_setting_event.dart';
import 'package:reel_t/events/user/google_sign_up/google_sign_up_event.dart';
import 'package:reel_t/events/user/send_email_otp/send_email_otp_event.dart';
import 'package:reel_t/models/setting/setting.dart';
import 'package:reel_t/screens/navigation/navigation_screen.dart';
import 'package:reel_t/screens/user/email_authenticate/email_authenticate_screen.dart';
import 'package:reel_t/screens/user/google_account_link/google_account_link_screen.dart';
import 'package:reel_t/screens/welcome/welcome_screen.dart';

import '../../../events/user/user_sign_in/user_sign_in_event.dart';
import '../../../models/user_profile/user_profile.dart';
import '../../../generated/abstract_bloc.dart';
import 'login_screen.dart';

class LoginBloc extends AbstractBloc<LoginScreenState>
    with
        UserSignInEvent,
        SendEmailOtpEvent,
        GoogleSignUpEvent,
        RetrieveUserSettingEvent,
        CreateUserSettingEvent {
  String email = "";
  String password = "";
  late UserProfile signedInUserProfile;
  void login() {
    var hashedPassword = appStore.security.hashPassword(password);
    sendUserSignInEvent(email, hashedPassword);
  }

  @override
  void onUserSignInEventDone(String e, UserProfile? signedInUserProfile) {
    if (e.isEmpty) {
      this.signedInUserProfile = signedInUserProfile!;
      sendRetrieveUserSettingEvent(signedInUserProfile.id);
      return;
    }
    state.showAlertDialog(
      title: "Login",
      content: e,
      confirm: () {
        state.popTopDisplay();
      },
    );
  }

  @override
  void onSendEmailOtpEventDone(bool isSent) {
    if (isSent) {
      state.stopLoading();
      state.pushToScreen(EmailAuthenticateScreen(
        email: signedInUserProfile.email.toLowerCase(),
        password: password,
        previousScreen: LoginScreenState.LOGIN_SCREEN,
      ));
    }
  }

  @override
  Future<void> onGoogleSignUpEventDone(String e) async {
    state.stopLoading();
    if (e.isEmpty) {
      return;
    }

    state.showAlertDialog(
      title: "Sign-in",
      content: e,
      confirm: () {
        state.popTopDisplay();
      },
    );
  }

  @override
  void onRetrieveUserSettingEventDone(Setting? setting) {
    if (setting != null) {
      if (setting.isTurnOffTwoFa) {
        state.stopLoading();
        appStore.localSetting.setUserSetting(setting);
        appStore.localUser.login(signedInUserProfile);
        state.pushToScreen(NavigationScreen(), isReplace: true);
        return;
      }

      sendSendEmailOtpEvent(email);
      return;
    }
    sendSendEmailOtpEvent(email);
  }

  @override
  void onCreateUserSettingEventDone(Setting? setting) {
    appStore.localSetting.setUserSetting(setting!);
    state.pushToScreen(NavigationScreen(), isReplace: true);
  }

  @override
  void onGoogleSignUpEventDoneWithExistsUserEmail(
      String e, GoogleSignInAccount googleSignInAccount) {
    state.showAlertDialog(
      title: "Sign-in",
      content: e,
      confirmTitle: "Link",
      cancelTitle: "Cancel",
      confirm: () {
        state.popTopDisplay();
        state.pushToScreen(
          GoogleAccountLinkScreen(googleSignInAccount: googleSignInAccount),
        );
      },
      cancel: () {
        state.popTopDisplay();
      },
    );
  }
  
  @override
  Future<void> onGoogleSignUpEventDoneWithSignIn(
      String e, UserProfile userProfile) async {
    await appStore.localUser.login(userProfile);
    await appStore.localSetting.syncUserSetting(userProfile.id);
    state.pushToScreen(NavigationScreen(), isReplace: true);
  }

  @override
  void onGoogleSignUpEventDoneWithSignUP(
      GoogleSignInAccount googleSignInAccount) {
    state.stopLoading();
    state.pushToScreen(GoogleAccountLinkScreen(
      googleSignInAccount: googleSignInAccount,
      isLinkAccountWithEmail: false,
    ));
  }
}

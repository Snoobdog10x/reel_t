import 'dart:async';

import 'package:reel_t/events/setting/create_user_setting/create_user_setting_event.dart';
import 'package:reel_t/events/user/retrieve_user_profile/retrieve_user_profile_event.dart';
import 'package:reel_t/events/user/send_email_otp/send_email_otp_event.dart';
import 'package:reel_t/events/user/user_sign_in/user_sign_in_event.dart';
import 'package:reel_t/events/user/user_sign_up/user_sign_up_event.dart';
import 'package:reel_t/events/user/verify_email_otp/verify_email_otp_event.dart';
import 'package:reel_t/models/setting/setting.dart';
import 'package:reel_t/screens/navigation/navigation_screen.dart';
import 'package:reel_t/screens/sub_setting_user/reset_password/reset_password_screen.dart';
import 'package:reel_t/screens/user/signup/signup_screen.dart';
import 'package:reel_t/screens/user/update_password/update_password_screen.dart';
import '../../../generated/abstract_bloc.dart';
import '../../../models/user_profile/user_profile.dart';
import '../../welcome/welcome_screen.dart';
import 'email_authenticate_screen.dart';

class EmailAuthenticateBloc extends AbstractBloc<EmailAuthenticateScreenState>
    with
        SendEmailOtpEvent,
        VerifyEmailOtpEvent,
        UserSignUpEvent,
        CreateUserSettingEvent,
        UserSignInEvent {
  String email = "";
  String password = "";
  void resendOTP() {
    sendSendEmailOtpEvent(email);
  }

  void verifyOTP(String otp) {
    state.startLoading();
    sendVerifyEmailOtpEvent(email, otp);
  }

  String convertSecondToMinute(int second) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    var min = second ~/ 60;
    var sec = second % 60;
    return "${twoDigits(min)}:${twoDigits(sec)}";
  }

  @override
  void onSendEmailOtpEventDone(bool isSent) {
    if (isSent) {
      notifyDataChanged();
      return;
    }
    state.showAlertDialog(
      title: "OTP Verification",
      content: "Server error, please try after 15 minute",
      confirm: () {
        state.popTopDisplay();
        state.popTopDisplay();
      },
    );
  }

  @override
  void onVerifyEmailOtpEventDone(bool isVerified, String verifyStatus) {
    if (isVerified) {
      var hashedPassword = appStore.security.hashPassword(password);
      if (state.widget.previousScreen == SignupScreenState.SIGN_UP_SCREEN) {
        sendUserSignUpEvent(email: email, password: hashedPassword);
        return;
      }

      if (state.widget.previousScreen ==
          ResetPasswordScreenState.RESET_PASSWORD_SCREEN) {
        state.stopLoading();
        state.pushToScreen(UpdatePasswordScreen());
        return;
      }

      sendUserSignInEvent(email, hashedPassword);
      return;
    }

    state.showAlertDialog(
      title: "OTP Verification",
      content: verifyStatus,
      confirm: () {
        state.popTopDisplay();
      },
    );
  }

  @override
  Future<void> onUserSignUpEventDone(
      String errorMessage, UserProfile? signedUser) async {
    if (errorMessage.isEmpty) {
      await appStore.localUser.login(signedUser!);
      sendCreateUserSettingEvent(signedUser.id);
      return;
    }

    state.showAlertDialog(
      title: "Sign-up",
      content: errorMessage,
      confirm: () {
        state.popTopDisplay();
      },
    );
  }

  @override
  Future<void> onCreateUserSettingEventDone(Setting? setting) async {
    if (setting != null) {
      await appStore.localSetting.setUserSetting(setting);
      state.pushToScreen(NavigationScreen(), isReplace: true);
    }
  }

  @override
  Future<void> onUserSignInEventDone(
      String e, UserProfile? signedInUserProfile) async {
    await appStore.localUser.login(signedInUserProfile!);
    await appStore.localSetting.syncUserSetting(signedInUserProfile.id);
    state.stopLoading();
    state.pushToScreen(NavigationScreen(), isReplace: true);
  }
}

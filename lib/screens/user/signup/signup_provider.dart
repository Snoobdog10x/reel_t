import '../../../events/user/user_sign_up/user_sign_up_event.dart';
import '../../../models/user_profile/user_profile.dart';
import '../../../generated/abstract_provider.dart';

class SignupProvider extends AbstractProvider with UserSignUpEvent {
  String name = "";
  String email = "";
  String password = "";
  late UserProfile userProfile;
  void signIn() {
    var hashedPassword = state.appStore.security.hashPassword(password);
    this.sendUserSignUpEvent(
      fullName: name,
      email: email,
      password: hashedPassword,
    );
  }

  @override
  void onUserSignUpEventDone(String errorMessage) {
    state.stopLoading();
    if (errorMessage.isEmpty) {
      state.showAlertDialog(
        title: "Sign-up",
        content: "Success",
        confirm: () {
          state.popTopDisplay();
        },
      );
      appStore.localUser.login(userProfile);
      return;
    }
    state.showAlertDialog(
      title: "Sign-up",
      content: errorMessage,
      confirm: () {},
    );
  }
}
